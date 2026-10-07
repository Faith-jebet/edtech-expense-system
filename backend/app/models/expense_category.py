"""Expense category model."""
from app import db
from datetime import datetime


class ExpenseCategory(db.Model):
    """Categories for expense classification."""
    
    __tablename__ = 'expense_categories'
    
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(20), unique=True, nullable=False, index=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    request_items = db.relationship('RequestItem', back_populates='category', lazy='dynamic')
    
    def __repr__(self):
        return f'<ExpenseCategory {self.code}: {self.name}>'
