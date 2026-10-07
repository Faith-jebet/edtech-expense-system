"""Reconciliation model for bank, mobile money, and petty cash."""
from app import db
from datetime import datetime


class Reconciliation(db.Model):
    """Reconciliation records for financial accounts."""
    
    __tablename__ = 'reconciliations'
    
    # Account type constants
    ACCOUNT_BANK = 'Bank'
    ACCOUNT_MOBILE_MONEY = 'Mobile Money'
    ACCOUNT_PETTY_CASH = 'Petty Cash'
    
    ACCOUNT_TYPES = [ACCOUNT_BANK, ACCOUNT_MOBILE_MONEY, ACCOUNT_PETTY_CASH]
    
    # Status constants
    STATUS_OPEN = 'Open'
    STATUS_EXPLAINED = 'Explained'
    STATUS_CLEARED = 'Cleared'
    
    STATUSES = [STATUS_OPEN, STATUS_EXPLAINED, STATUS_CLEARED]
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Account and period
    account_type = db.Column(db.String(50), nullable=False, index=True)
    account_name = db.Column(db.String(200), nullable=False)
    account_number = db.Column(db.String(100))
    period_start = db.Column(db.Date, nullable=False, index=True)
    period_end = db.Column(db.Date, nullable=False, index=True)
    
    # Balances
    opening_balance = db.Column(db.DECIMAL(14, 2), nullable=False)
    system_closing_balance = db.Column(db.DECIMAL(14, 2), nullable=False)
    actual_closing_balance = db.Column(db.DECIMAL(14, 2), nullable=False)
    difference = db.Column(db.DECIMAL(14, 2), nullable=False)
    
    # Reconciliation details
    status = db.Column(db.String(20), default=STATUS_OPEN, nullable=False, index=True)
    explanation = db.Column(db.Text)
    
    # Separation of duties
    prepared_by_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    reviewed_by_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    prepared_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    reviewed_at = db.Column(db.DateTime)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    prepared_by = db.relationship('User', foreign_keys=[prepared_by_id])
    reviewed_by = db.relationship('User', foreign_keys=[reviewed_by_id])
    items = db.relationship('ReconciliationItem', back_populates='reconciliation', lazy='dynamic',
                           cascade='all, delete-orphan')
    
    @property
    def has_unexplained_difference(self):
        """Check if there's an unexplained difference."""
        return self.status == self.STATUS_OPEN and float(abs(self.difference)) > 0.01
    
    def __repr__(self):
        return f'<Reconciliation {self.account_name} {self.period_start} to {self.period_end}>'


class ReconciliationItem(db.Model):
    """Individual items in reconciliation (from statement import or manual entry)."""
    
    __tablename__ = 'reconciliation_items'
    
    id = db.Column(db.Integer, primary_key=True)
    reconciliation_id = db.Column(db.Integer, db.ForeignKey('reconciliations.id'), nullable=False, index=True)
    
    # Transaction details
    transaction_date = db.Column(db.Date, nullable=False)
    description = db.Column(db.Text, nullable=False)
    reference = db.Column(db.String(200))
    debit = db.Column(db.DECIMAL(14, 2), default=0, nullable=False)
    credit = db.Column(db.DECIMAL(14, 2), default=0, nullable=False)
    
    # Matching
    matched = db.Column(db.Boolean, default=False, nullable=False)
    matched_request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'))
    matched_receipt_id = db.Column(db.Integer, db.ForeignKey('income_receipts.id'))
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    reconciliation = db.relationship('Reconciliation', back_populates='items')
    matched_request = db.relationship('ExpenseRequest', foreign_keys=[matched_request_id])
    matched_receipt = db.relationship('IncomeReceipt', foreign_keys=[matched_receipt_id])
    
    def __repr__(self):
        return f'<ReconciliationItem {self.reference}: {self.debit or self.credit}>'
