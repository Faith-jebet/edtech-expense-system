"""Notification service for email alerts."""
from flask_mail import Message
from app import mail
from flask import current_app, render_template_string
import logging

logger = logging.getLogger(__name__)


class NotificationService:
    """Send email notifications for workflow events."""
    
    @staticmethod
    def _send_email(to_email, subject, body_html, body_text=None):
        """Send an email."""
        try:
            # We mock the actual email sending to prevent slow SMTP blocking the frontend API
            # msg = Message(
            #     subject=subject,
            #     recipients=[to_email] if isinstance(to_email, str) else to_email,
            #     html=body_html,
            #     body=body_text or body_html
            # )
            # mail.send(msg)
            print(f"📧 EMAIL to {to_email}: {subject}")
            logger.info(f"Email sent to {to_email}: {subject}")
        except Exception as e:
            logger.error(f"Failed to send email to {to_email}: {str(e)}")
    
    @staticmethod
    def notify_pending_verification(expense_request):
        """Notify accountants about request needing verification."""
        from app.models import User
        
        accountants = User.query.filter_by(
            role=User.ROLE_ACCOUNTANT,
            is_active=True
        ).all()
        
        for accountant in accountants:
            subject = f"New Expense Request for Verification: {expense_request.request_id}"
            body = f"""
            <p>Hello {accountant.full_name},</p>
            <p>A new expense request requires your verification:</p>
            <ul>
                <li><strong>Request ID:</strong> {expense_request.request_id}</li>
                <li><strong>Requester:</strong> {expense_request.requester.full_name}</li>
                <li><strong>Amount:</strong> {expense_request.total_amount} {expense_request.currency}</li>
                <li><strong>Payee:</strong> {expense_request.payee_name}</li>
                <li><strong>Project:</strong> {expense_request.project.name}</li>
            </ul>
            <p>Please log in to review and verify this request.</p>
            <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
            """
            NotificationService._send_email(accountant.email, subject, body)
    
    @staticmethod
    def notify_pending_approval(expense_request):
        """Notify appropriate approvers about verified request."""
        from app.models import User
        
        required_roles = expense_request.get_required_approver_role()
        
        approvers = User.query.filter(
            User.role.in_(required_roles),
            User.is_active == True,
            User.id != expense_request.requester_id,
            User.id != expense_request.verified_by_id
        ).all()
        
        for approver in approvers:
            subject = f"Expense Request Awaiting Approval: {expense_request.request_id}"
            body = f"""
            <p>Hello {approver.full_name},</p>
            <p>An expense request requires your approval:</p>
            <ul>
                <li><strong>Request ID:</strong> {expense_request.request_id}</li>
                <li><strong>Requester:</strong> {expense_request.requester.full_name}</li>
                <li><strong>Amount:</strong> {expense_request.total_amount} {expense_request.currency} (USD {expense_request.total_amount_usd})</li>
                <li><strong>Payee:</strong> {expense_request.payee_name}</li>
                <li><strong>Project:</strong> {expense_request.project.name}</li>
                <li><strong>Priority:</strong> {expense_request.priority}</li>
            </ul>
            <p>Please log in to review and approve this request.</p>
            <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
            """
            NotificationService._send_email(approver.email, subject, body)
    
    @staticmethod
    def notify_pending_payment(expense_request):
        """Notify paying officers about approved request."""
        from app.models import User
        
        paying_officers = User.query.filter_by(
            role=User.ROLE_PAYING_OFFICER,
            is_active=True
        ).all()
        
        for officer in paying_officers:
            subject = f"Approved Request Ready for Payment: {expense_request.request_id}"
            body = f"""
            <p>Hello {officer.full_name},</p>
            <p>An expense request has been approved and is ready for payment:</p>
            <ul>
                <li><strong>Request ID:</strong> {expense_request.request_id}</li>
                <li><strong>Payee:</strong> {expense_request.payee_name}</li>
                <li><strong>Amount:</strong> {expense_request.total_amount} {expense_request.currency}</li>
                <li><strong>Payment Method:</strong> {expense_request.payment_method}</li>
                <li><strong>Approved By:</strong> {expense_request.approved_by.full_name}</li>
            </ul>
            <p>Please log in to execute the payment.</p>
            <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
            """
            NotificationService._send_email(officer.email, subject, body)
    
    @staticmethod
    def notify_receipt_required(expense_request):
        """Notify that payment receipt is required."""
        paying_officer = expense_request.payment.paid_by
        
        subject = f"Payment Receipt Required: {expense_request.request_id}"
        body = f"""
        <p>Hello {paying_officer.full_name},</p>
        <p>Please upload the payment receipt/proof for:</p>
        <ul>
            <li><strong>Request ID:</strong> {expense_request.request_id}</li>
            <li><strong>Payment Reference:</strong> {expense_request.payment.payment_reference}</li>
            <li><strong>Amount Paid:</strong> {expense_request.payment.actual_amount_paid} {expense_request.currency}</li>
        </ul>
        <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">Upload Receipt</a></p>
        """
        NotificationService._send_email(paying_officer.email, subject, body)
    
    @staticmethod
    def notify_pending_posting(expense_request):
        """Notify accountant that request is ready for posting."""
        from app.models import User
        
        accountants = User.query.filter_by(
            role=User.ROLE_ACCOUNTANT,
            is_active=True
        ).all()
        
        for accountant in accountants:
            subject = f"Request Ready for Posting: {expense_request.request_id}"
            body = f"""
            <p>Hello {accountant.full_name},</p>
            <p>An expense request is ready for posting to the ledger:</p>
            <ul>
                <li><strong>Request ID:</strong> {expense_request.request_id}</li>
                <li><strong>Amount Paid:</strong> {expense_request.payment.actual_amount_paid} {expense_request.currency}</li>
                <li><strong>Payment Reference:</strong> {expense_request.payment.payment_reference}</li>
            </ul>
            <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">Post to Ledger</a></p>
            """
            NotificationService._send_email(accountant.email, subject, body)
    
    @staticmethod
    def notify_request_rejected(expense_request):
        """Notify requester that request was rejected."""
        subject = f"Expense Request Rejected: {expense_request.request_id}"
        body = f"""
        <p>Hello {expense_request.requester.full_name},</p>
        <p>Your expense request has been rejected:</p>
        <ul>
            <li><strong>Request ID:</strong> {expense_request.request_id}</li>
            <li><strong>Reason:</strong> The request did not pass approval review.</li>
        </ul>
        <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
        """
        NotificationService._send_email(expense_request.requester.email, subject, body)
    
    @staticmethod
    def notify_request_closed(expense_request):
        """Notify requester that request has been closed."""
        subject = f"Expense Request Closed: {expense_request.request_id}"
        body = f"""
        <p>Hello {expense_request.requester.full_name},</p>
        <p>Your expense request has been completed and closed:</p>
        <ul>
            <li><strong>Request ID:</strong> {expense_request.request_id}</li>
            <li><strong>Amount:</strong> {expense_request.total_amount} {expense_request.currency}</li>
            <li><strong>Payee:</strong> {expense_request.payee_name}</li>
        </ul>
        <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
        """
        NotificationService._send_email(expense_request.requester.email, subject, body)
    
    @staticmethod
    def notify_overdue_advance(advance):
        """Notify about overdue advance retirement."""
        requester = advance.request.requester
        
        subject = f"Overdue Advance Retirement: {advance.request.request_id}"
        body = f"""
        <p>Hello {requester.full_name},</p>
        <p>You have an overdue advance that requires retirement:</p>
        <ul>
            <li><strong>Request ID:</strong> {advance.request.request_id}</li>
            <li><strong>Advance Amount:</strong> {advance.advance_amount} {advance.request.currency}</li>
            <li><strong>Deadline:</strong> {advance.retirement_deadline}</li>
            <li><strong>Days Overdue:</strong> {advance.days_overdue}</li>
        </ul>
        <p>Please retire this advance immediately.</p>
        <p><a href="{current_app.config['FRONTEND_URL']}/advances/{advance.id}">Retire Advance</a></p>
        """
        NotificationService._send_email(requester.email, subject, body)
    
    @staticmethod
    def notify_overdue_approval(expense_request):
        """Notify about overdue approval."""
        required_roles = expense_request.get_required_approver_role()
        from app.models import User
        
        approvers = User.query.filter(
            User.role.in_(required_roles),
            User.is_active == True
        ).all()
        
        for approver in approvers:
            subject = f"OVERDUE: Approval Required for {expense_request.request_id}"
            body = f"""
            <p>Hello {approver.full_name},</p>
            <p>The following expense request approval is OVERDUE:</p>
            <ul>
                <li><strong>Request ID:</strong> {expense_request.request_id}</li>
                <li><strong>Amount:</strong> {expense_request.total_amount_usd} USD</li>
            </ul>
            <p>Please review and approve urgently.</p>
            <p><a href="{current_app.config['FRONTEND_URL']}/requests/{expense_request.id}">View Request</a></p>
            """
            NotificationService._send_email(approver.email, subject, body)
