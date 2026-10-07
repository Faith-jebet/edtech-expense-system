"""Attachment model for supporting documents."""
from app import db
from datetime import datetime


class Attachment(db.Model):
    """File attachments for expense requests."""
    
    __tablename__ = 'attachments'
    
    # Attachment types
    TYPE_QUOTATION = 'Quotation'
    TYPE_INVOICE = 'Invoice'
    TYPE_PO = 'Purchase Order'
    TYPE_CONTRACT = 'Contract'
    TYPE_RECEIPT = 'Receipt'
    TYPE_PROOF_OF_PAYMENT = 'Proof of Payment'
    TYPE_CASH_VOUCHER = 'Cash Voucher'
    TYPE_OTHER = 'Other'
    
    TYPES = [
        TYPE_QUOTATION,
        TYPE_INVOICE,
        TYPE_PO,
        TYPE_CONTRACT,
        TYPE_RECEIPT,
        TYPE_PROOF_OF_PAYMENT,
        TYPE_CASH_VOUCHER,
        TYPE_OTHER
    ]
    
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'), nullable=False, index=True)
    attachment_type = db.Column('file_type', db.String(50), nullable=False)
    filename = db.Column('file_name', db.String(255), nullable=False)
    filepath = db.Column('file_path', db.String(500), nullable=False)
    filesize = db.Column('file_size', db.Integer, nullable=False)
    uploaded_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column('uploaded_at', db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    request = db.relationship('ExpenseRequest', back_populates='attachments')
    uploaded_by = db.relationship('User')
    
    def __repr__(self):
        return f'<Attachment {self.filename} ({self.attachment_type})>'
