"""Income/receipt model for money received."""
from app import db
from datetime import datetime


class IncomeReceipt(db.Model):
    """Track money received (income)."""
    
    __tablename__ = 'income_receipts'
    
    id = db.Column(db.Integer, primary_key=True)
    receipt_id = db.Column(db.String(50), unique=True, nullable=False, index=True)
    
    # Receipt details
    source = db.Column(db.String(200), nullable=False)  # Who paid
    project_id = db.Column(db.Integer, db.ForeignKey('projects.id'), nullable=False, index=True)
    description = db.Column(db.Text, nullable=False)
    
    # Amount
    currency = db.Column(db.String(10), nullable=False)
    amount = db.Column(db.DECIMAL(14, 2), nullable=False)
    exchange_rate_to_usd = db.Column(db.DECIMAL(10, 6), nullable=False)
    amount_usd = db.Column(db.DECIMAL(14, 2), nullable=False)
    
    # Payment details
    payment_method = db.Column(db.String(50), nullable=False)
    reference_number = db.Column(db.String(200))
    receipt_date = db.Column(db.Date, nullable=False, index=True)
    
    # Proof attachment
    proof_attachment_id = db.Column(db.Integer, db.ForeignKey('attachments.id'))
    
    # Recording
    recorded_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    ledger_reference = db.Column(db.String(200))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    project = db.relationship('Project', back_populates='income_receipts')
    recorded_by = db.relationship('User')
    proof_attachment = db.relationship('Attachment', foreign_keys=[proof_attachment_id])
    
    def __repr__(self):
        return f'<IncomeReceipt {self.receipt_id}: {self.amount} {self.currency}>'
