"""Advance tracking model."""
from app import db
from datetime import datetime


class Advance(db.Model):
    """Track advances and their retirement."""
    
    __tablename__ = 'advances'
    
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'), nullable=False, unique=True, index=True)
    
    # Advance details
    advance_amount = db.Column(db.DECIMAL(14, 2), nullable=False)
    retirement_deadline = db.Column(db.Date, nullable=False)
    is_retired = db.Column(db.Boolean, default=False, nullable=False)
    
    # Retirement details
    retired_amount = db.Column(db.DECIMAL(14, 2))
    retirement_date = db.Column(db.Date)
    retirement_reference = db.Column(db.String(200))
    retirement_notes = db.Column(db.Text)
    
    # Reminder tracking
    last_reminder_sent = db.Column(db.DateTime)
    reminder_count = db.Column(db.Integer, default=0, nullable=False)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    request = db.relationship('ExpenseRequest', back_populates='advance')
    
    @property
    def is_overdue(self):
        """Check if advance retirement is overdue."""
        if self.is_retired:
            return False
        return datetime.utcnow().date() > self.retirement_deadline
    
    @property
    def days_overdue(self):
        """Calculate days overdue."""
        if not self.is_overdue:
            return 0
        return (datetime.utcnow().date() - self.retirement_deadline).days
    
    def __repr__(self):
        return f'<Advance {self.request.request_id}: {self.advance_amount}>'
