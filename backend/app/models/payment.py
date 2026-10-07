"""Payment execution model."""
from app import db
from datetime import datetime


class Payment(db.Model):
    """Payment execution records."""
    
    __tablename__ = 'payments'
    
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'), nullable=False, unique=True, index=True)
    paid_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    
    # Payment details
    payment_reference = db.Column(db.String(200), nullable=False)  # Transaction ID / Reference
    payment_method = db.Column(db.String(50), nullable=False)
    actual_amount_paid = db.Column(db.DECIMAL(14, 2), nullable=False)
    payment_date = db.Column(db.Date, nullable=False)
    payment_notes = db.Column(db.Text)
    
    # Receipt/Proof
    receipt_attached = db.Column(db.Boolean, default=False, nullable=False)
    receipt_attachment_id = db.Column(db.Integer, db.ForeignKey('attachments.id'))
    
    # Ledger posting (by accountant)
    ledger_reference = db.Column(db.String(200))
    posted_by_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    posted_at = db.Column(db.DateTime)
    posting_notes = db.Column(db.Text)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    request = db.relationship('ExpenseRequest', back_populates='payment')
    paid_by = db.relationship('User', foreign_keys=[paid_by_id], back_populates='payments_made')
    posted_by = db.relationship('User', foreign_keys=[posted_by_id])
    receipt_attachment = db.relationship('Attachment', foreign_keys=[receipt_attachment_id])
    
    def __repr__(self):
        return f'<Payment {self.payment_reference} for {self.request.request_id}>'
