"""Project/Cost Centre model."""
from app import db
from datetime import datetime


class Project(db.Model):
    """Project or cost centre for expense tracking."""
    
    __tablename__ = 'projects'
    
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(20), unique=True, nullable=False, index=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text)
    budget = db.Column(db.DECIMAL(14, 2))
    currency = db.Column(db.String(3), default='USD')
    start_date = db.Column(db.Date)
    end_date = db.Column(db.Date)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    expense_requests = db.relationship('ExpenseRequest', back_populates='project', lazy='dynamic')
    income_receipts = db.relationship('IncomeReceipt', back_populates='project', lazy='dynamic')
    
    def __repr__(self):
        return f'<Project {self.code}: {self.name}>'
