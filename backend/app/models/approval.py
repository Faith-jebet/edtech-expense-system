"""Approval records model."""
from app import db
from datetime import datetime


class Approval(db.Model):
    """Approval records for expense requests."""
    
    __tablename__ = 'approvals'
    
    # Decision constants
    DECISION_APPROVED = 'Approved'
    DECISION_REJECTED = 'Rejected'
    
    DECISIONS = [DECISION_APPROVED, DECISION_REJECTED]
    
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey('expense_requests.id'), nullable=False, index=True)
    approver_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False, index=True)
    decision = db.Column(db.String(20), nullable=False)
    comments = db.Column(db.Text)
    signature_path = db.Column(db.String(255))  # Path to signature image if uploaded
    signature_text = db.Column(db.String(200))  # Typed confirmation
    ip_address = db.Column(db.String(45))
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    # Relationships
    request = db.relationship('ExpenseRequest', back_populates='approvals')
    approver = db.relationship('User', foreign_keys=[approver_id], back_populates='approvals_given')
    
    def __repr__(self):
        return f'<Approval {self.request.request_id} by {self.approver.full_name}: {self.decision}>'
