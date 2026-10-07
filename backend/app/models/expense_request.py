"""Expense request model."""
from app import db
from datetime import datetime
from decimal import Decimal


class ExpenseRequest(db.Model):
    """Expense/Payment request with workflow automation."""
    
    __tablename__ = 'expense_requests'
    
    # Status constants (workflow states)
    STATUS_DRAFT = 'Draft'
    STATUS_SUBMITTED = 'Submitted'
    STATUS_VERIFIED = 'Verified'
    STATUS_APPROVED = 'Approved'
    STATUS_REJECTED = 'Rejected'
    STATUS_PAID = 'Paid'
    STATUS_POSTED = 'Posted'
    STATUS_CLOSED = 'Closed'
    
    STATUSES = [
        STATUS_DRAFT,
        STATUS_SUBMITTED,
        STATUS_VERIFIED,
        STATUS_APPROVED,
        STATUS_REJECTED,
        STATUS_PAID,
        STATUS_POSTED,
        STATUS_CLOSED
    ]
    
    # Database columns (matching actual schema)
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.String(50), unique=True, nullable=False, index=True)
    project_id = db.Column(db.Integer, db.ForeignKey('projects.id'), nullable=False, index=True)
    requester_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    request_date = db.Column(db.Date, nullable=False, index=True)
    purpose = db.Column(db.Text, nullable=False)
    payee_name = db.Column(db.String(200), nullable=False)
    payment_method = db.Column(db.String(50), nullable=False)
    currency = db.Column(db.String(3), nullable=False)
    total_amount = db.Column(db.DECIMAL(14, 2), nullable=False)
    exchange_rate_to_usd = db.Column(db.DECIMAL(10, 6))
    total_amount_usd = db.Column(db.DECIMAL(14, 2), nullable=False)
    status = db.Column(db.String(50), default=STATUS_DRAFT, nullable=False, index=True)
    
    # Workflow tracking
    verified_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), index=True)
    verified_at = db.Column(db.DateTime)
    approved_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), index=True)
    approved_at = db.Column(db.DateTime)
    paid_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), index=True)
    paid_at = db.Column(db.DateTime)
    payment_reference = db.Column(db.String(100))
    actual_amount_paid = db.Column(db.DECIMAL(14, 2))
    posted_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), index=True)
    posted_at = db.Column(db.DateTime)
    ledger_reference = db.Column(db.String(100))
    closed_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), index=True)
    closed_at = db.Column(db.DateTime)
    
    # Form fields from document
    priority = db.Column(db.String(20), default='Normal')
    budget_status = db.Column(db.String(50), default='Within Budget')
    
    # Other fields
    is_split_purchase = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    requester = db.relationship('User', foreign_keys=[requester_id], back_populates='submitted_requests')
    verified_by = db.relationship('User', foreign_keys=[verified_by_id])
    approved_by = db.relationship('User', foreign_keys=[approved_by_id])
    paid_by = db.relationship('User', foreign_keys=[paid_by_id])
    posted_by = db.relationship('User', foreign_keys=[posted_by_id])
    closed_by = db.relationship('User', foreign_keys=[closed_by_id])
    
    project = db.relationship('Project', back_populates='expense_requests')
    items = db.relationship('RequestItem', back_populates='request', lazy='dynamic', 
                           cascade='all, delete-orphan')
    attachments = db.relationship('Attachment', back_populates='request', lazy='dynamic',
                                 cascade='all, delete-orphan')
    approvals = db.relationship('Approval', back_populates='request', lazy='dynamic',
                               cascade='all, delete-orphan')
    payment = db.relationship('Payment', back_populates='request', uselist=False,
                             cascade='all, delete-orphan')
    advance = db.relationship('Advance', back_populates='request', uselist=False,
                             cascade='all, delete-orphan')
    
    def can_transition_to(self, new_status, user):
        """
        Check if request can transition to new status.
        Returns (can_transition: bool, reason: str)
        """
        # Draft -> Submitted: requester can submit
        if self.status == self.STATUS_DRAFT and new_status == self.STATUS_SUBMITTED:
            if user.id != self.requester_id:
                return False, "Only the requester can submit this request"
            if not self.items.count():
                return False, "Request must have at least one line item"
            return True, None
        
        # Submitted -> Verified: accountant can verify
        if self.status == self.STATUS_SUBMITTED and new_status == self.STATUS_VERIFIED:
            if not user.can_verify():
                return False, "Only an Accountant can verify requests"
            if user.id == self.requester_id:
                return False, "Separation of duties: requester cannot verify their own request"
            if float(self.total_amount_usd) > 100 and self.attachments.count() == 0:
                return False, "Quotation/Invoice must be attached for amounts over USD 100"
            return True, None
        
        # Verified -> Approved: appropriate approver
        if self.status == self.STATUS_VERIFIED and new_status == self.STATUS_APPROVED:
            if user.id == self.requester_id:
                return False, "Separation of duties: requester cannot approve their own request"
            if user.id == self.verified_by_id:
                return False, "Separation of duties: verifier cannot approve the same request"
            if not user.can_approve(float(self.total_amount_usd)):
                return False, f"User lacks approval authority for amount USD {self.total_amount_usd}"
            return True, None
        
        # Submitted, Verified or Approved -> Rejected
        if new_status == self.STATUS_REJECTED:
            if self.status not in [self.STATUS_SUBMITTED, self.STATUS_VERIFIED, self.STATUS_APPROVED]:
                return False, f"Cannot reject request in status {self.status}"
            if user.id == self.requester_id:
                return False, "Separation of duties: requester cannot reject their own request"
            if self.status == self.STATUS_SUBMITTED and not user.can_verify():
                return False, "Only an Accountant can reject a submitted request"
            if self.status in [self.STATUS_VERIFIED, self.STATUS_APPROVED] and not user.can_approve(float(self.total_amount_usd)):
                return False, "Only an authorized Approver can reject this request"
            return True, None
        
        # Approved -> Paid: paying officer can pay
        if self.status == self.STATUS_APPROVED and new_status == self.STATUS_PAID:
            if not user.can_pay():
                return False, "Only a Paying Officer can execute payments"
            if user.id == self.requester_id:
                return False, "Separation of duties: requester cannot pay their own request"
            return True, None
        
        # Paid -> Posted: accountant posts to ledger
        if self.status == self.STATUS_PAID and new_status == self.STATUS_POSTED:
            if not user.can_post():
                return False, "Only an Accountant can post to ledger"
            if user.id == self.requester_id:
                return False, "Separation of duties: requester cannot post their own request"
            if not self.payment_reference:
                return False, "Payment reference required before posting"
            if not any(
                attachment.attachment_type in ['Receipt', 'Proof of Payment']
                for attachment in self.attachments
            ):
                return False, "Receipt or proof of payment is required before posting"
            return True, None
        
        # Posted -> Closed: accountant closes
        if self.status == self.STATUS_POSTED and new_status == self.STATUS_CLOSED:
            if not user.can_post():
                return False, "Only an Accountant can close requests"
            if not self.ledger_reference:
                return False, "Ledger reference required before closing"
            return True, None
        
        return False, f"Invalid status transition from {self.status} to {new_status}"
    
    def get_required_approver_role(self):
        """Determine which role(s) can approve this request based on amount."""
        from app.models.user import User
        amount = float(self.total_amount_usd)
        
        # Escalation for Director/MD requesters
        if self.requester.role == User.ROLE_DIRECTOR:
            return [User.ROLE_MANAGING_DIRECTOR]
        if self.requester.role == User.ROLE_MANAGING_DIRECTOR:
            return [User.ROLE_DIRECTOR]
        
        # Standard approval routing
        if amount <= 100:
            return [User.ROLE_OPERATION_MANAGER, User.ROLE_MANAGER, User.ROLE_DIRECTOR, User.ROLE_MANAGING_DIRECTOR]
        elif amount <= 500:
            return [User.ROLE_DIRECTOR, User.ROLE_MANAGING_DIRECTOR]
        else:
            return [User.ROLE_DIRECTOR, User.ROLE_MANAGING_DIRECTOR]
    
    def __repr__(self):
        return f'<ExpenseRequest {self.request_id} ({self.status})>'


class RequestItem(db.Model):
    """Line items for expense requests."""
    
    __tablename__ = 'request_items'
    
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'), nullable=False, index=True)
    category_id = db.Column(db.Integer, db.ForeignKey('expense_categories.id'), nullable=False, index=True)
    description = db.Column(db.Text, nullable=False)
    quantity = db.Column(db.DECIMAL(10, 2), nullable=False)
    unit_price = db.Column(db.DECIMAL(14, 2), nullable=False)
    total_price = db.Column(db.DECIMAL(14, 2), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    request = db.relationship('ExpenseRequest', back_populates='items')
    category = db.relationship('ExpenseCategory', back_populates='request_items')
    
    def __repr__(self):
        return f'<RequestItem {self.description[:30]}>'
