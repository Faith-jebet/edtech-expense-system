"""Workflow service for expense request state transitions."""
from app import db
from app.models import ExpenseRequest, AuditLog, User
from app.services.settings_service import SettingsService
from app.services.notification_service import NotificationService
from datetime import datetime, timedelta
from flask import request


class WorkflowService:
    """Manages expense request workflow transitions and business rules."""
    
    @staticmethod
    def submit_request(expense_request, user, ip_address=None):
        """
        Submit a draft request.
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_SUBMITTED, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Check for split purchases
        WorkflowService._check_split_purchase(expense_request)
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_SUBMITTED
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_STATUS_CHANGE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Request submitted: {expense_request.request_id}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify accountant for verification
        NotificationService.notify_pending_verification(expense_request)
        
        return True, "Request submitted successfully", expense_request
    
    @staticmethod
    def verify_request(expense_request, user, ip_address=None):
        """
        Verify a submitted request (Accountant).
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_VERIFIED, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_VERIFIED
        expense_request.verified_at = datetime.utcnow()
        expense_request.verified_by_id = user.id
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_STATUS_CHANGE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Request verified by {user.full_name}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify appropriate approver based on amount
        NotificationService.notify_pending_approval(expense_request)
        
        return True, "Request verified successfully", expense_request
    
    @staticmethod
    def approve_request(expense_request, user, comments=None, signature_text=None, 
                       signature_path=None, ip_address=None):
        """
        Approve a verified request.
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_APPROVED, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Create approval record
        from app.models import Approval
        approval = Approval(
            request_id=expense_request.id,
            approver_id=user.id,
            decision=Approval.DECISION_APPROVED,
            comments=comments,
            signature_text=signature_text,
            signature_path=signature_path,
            ip_address=ip_address
        )
        db.session.add(approval)
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_APPROVED
        expense_request.approved_at = datetime.utcnow()
        expense_request.approved_by_id = user.id
        
        # Set SLA for payment
        payment_sla_days = SettingsService.get('payment_sla_days', 3)
        expense_request.payment_due_date = datetime.utcnow() + timedelta(days=payment_sla_days)
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_APPROVE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Request approved by {user.full_name}. Comments: {comments or 'None'}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify paying officer
        NotificationService.notify_pending_payment(expense_request)
        
        return True, "Request approved successfully", expense_request
    
    @staticmethod
    def reject_request(expense_request, user, reason, ip_address=None):
        """
        Reject a request (from Verified or Approved status).
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, trans_reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_REJECTED, user
        )
        
        if not can_transition:
            return False, trans_reason, None
        
        if not reason:
            return False, "Rejection reason is required", None
        
        # Create rejection approval record
        from app.models import Approval
        approval = Approval(
            request_id=expense_request.id,
            approver_id=user.id,
            decision=Approval.DECISION_REJECTED,
            comments=reason,
            ip_address=ip_address
        )
        db.session.add(approval)
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_REJECTED
        expense_request.rejected_at = datetime.utcnow()
        expense_request.rejected_by_id = user.id
        expense_request.rejection_reason = reason
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_REJECT,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Request rejected by {user.full_name}. Reason: {reason}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify requester
        NotificationService.notify_request_rejected(expense_request)
        
        return True, "Request rejected", expense_request
    
    @staticmethod
    def execute_payment(expense_request, user, payment_reference, actual_amount_paid,
                       payment_date, payment_notes=None, ip_address=None):
        """
        Execute payment (Paying Officer).
        Returns (success: bool, message: str, payment: Payment|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_PAID, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Create payment record
        from app.models import Payment
        payment = Payment(
            request_id=expense_request.id,
            paid_by_id=user.id,
            payment_reference=payment_reference,
            payment_method=expense_request.payment_method,
            actual_amount_paid=actual_amount_paid,
            payment_date=payment_date,
            payment_notes=payment_notes
        )
        db.session.add(payment)
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_PAID
        expense_request.paid_at = datetime.utcnow()
        
        # Set SLA for receipt upload
        receipt_sla_days = SettingsService.get('receipt_sla_days', 5)
        expense_request.receipt_due_date = datetime.utcnow() + timedelta(days=receipt_sla_days)
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_PAYMENT,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Payment executed. Ref: {payment_reference}, Amount: {actual_amount_paid}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify for receipt upload
        NotificationService.notify_receipt_required(expense_request)
        
        return True, "Payment executed successfully", payment
    
    @staticmethod
    def attach_payment_proof(expense_request, user, attachment, ip_address=None):
        """
        Attach payment proof/receipt.
        Records evidence while the request remains Paid until ledger posting.
        """
        if not expense_request.payment:
            return False, "No payment record found", None
        
        # Update payment record
        expense_request.payment.receipt_attached = True
        expense_request.payment.receipt_attachment_id = attachment.id
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_STATUS_CHANGE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Payment proof attached: {attachment.filename}",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify accountant for posting
        NotificationService.notify_pending_posting(expense_request)
        
        return True, "Payment proof attached successfully", expense_request
    
    @staticmethod
    def post_to_ledger(expense_request, user, ledger_reference, posting_notes=None, 
                       ip_address=None):
        """
        Post to ledger (Accountant).
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_POSTED, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Update payment record
        expense_request.payment.ledger_reference = ledger_reference
        expense_request.payment.posted_by_id = user.id
        expense_request.payment.posted_at = datetime.utcnow()
        expense_request.payment.posting_notes = posting_notes
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_POSTED
        expense_request.posted_at = datetime.utcnow()
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_STATUS_CHANGE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note=f"Posted to ledger: {ledger_reference}",
            ip_address=ip_address
        )
        db.session.commit()
        
        return True, "Posted to ledger successfully", expense_request
    
    @staticmethod
    def close_request(expense_request, user, ip_address=None):
        """
        Close a posted request (Accountant).
        Returns (success: bool, message: str, request: ExpenseRequest|None)
        """
        can_transition, reason = expense_request.can_transition_to(
            ExpenseRequest.STATUS_CLOSED, user
        )
        
        if not can_transition:
            return False, reason, None
        
        # Update status
        old_status = expense_request.status
        expense_request.status = ExpenseRequest.STATUS_CLOSED
        expense_request.closed_at = datetime.utcnow()
        
        # Update project spent amount
        expense_request.project.spent_usd += expense_request.total_amount_usd
        
        db.session.commit()
        
        # Audit log
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_STATUS_CHANGE,
            entity_type='ExpenseRequest',
            entity_id=expense_request.id,
            note="Request closed",
            ip_address=ip_address
        )
        db.session.commit()
        
        # Notify requester
        NotificationService.notify_request_closed(expense_request)
        
        return True, "Request closed successfully", expense_request
    
    @staticmethod
    def _check_split_purchase(expense_request):
        """
        Check for potential split purchases (same payee + project within 7 days).
        Flags if combined amount crosses higher approval band.
        """
        from datetime import timedelta
        from sqlalchemy import func
        
        # Look for requests to same payee for same project within 7 days
        seven_days_ago = expense_request.created_at - timedelta(days=7)
        
        related_requests = ExpenseRequest.query.filter(
            ExpenseRequest.payee_name == expense_request.payee_name,
            ExpenseRequest.project_id == expense_request.project_id,
            ExpenseRequest.created_at >= seven_days_ago,
            ExpenseRequest.id != expense_request.id,
            ExpenseRequest.status != ExpenseRequest.STATUS_REJECTED
        ).all()
        
        if related_requests:
            total_usd = float(expense_request.total_amount_usd)
            for req in related_requests:
                total_usd += float(req.total_amount_usd)
            
            # Check if combined amount crosses approval bands
            current_amount = float(expense_request.total_amount_usd)
            
            # If individual is <= 100 but combined > 100
            if current_amount <= 100 and total_usd > 100:
                expense_request.split_purchase_flag = True
                expense_request.split_purchase_note = (
                    f"Combined with {len(related_requests)} recent request(s) to same payee "
                    f"totals USD {total_usd:.2f}, crossing USD 100 threshold."
                )
            # If individual is <= 500 but combined > 500
            elif current_amount <= 500 and total_usd > 500:
                expense_request.split_purchase_flag = True
                expense_request.split_purchase_note = (
                    f"Combined with {len(related_requests)} recent request(s) to same payee "
                    f"totals USD {total_usd:.2f}, crossing USD 500 threshold."
                )
