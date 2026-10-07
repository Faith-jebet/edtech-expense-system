"""Audit log model for immutable activity tracking."""
from app import db
from datetime import datetime


class AuditLog(db.Model):
    """
    Immutable audit log for all significant actions.
    Protected by database triggers against UPDATE and DELETE.
    """
    
    __tablename__ = 'audit_log'
    
    # Action types
    ACTION_CREATE = 'CREATE'
    ACTION_UPDATE = 'UPDATE'
    ACTION_DELETE = 'DELETE'
    ACTION_STATUS_CHANGE = 'STATUS_CHANGE'
    ACTION_APPROVE = 'APPROVE'
    ACTION_REJECT = 'REJECT'
    ACTION_PAYMENT = 'PAYMENT'
    ACTION_LOGIN = 'LOGIN'
    ACTION_LOGOUT = 'LOGOUT'
    ACTION_UPLOAD = 'UPLOAD'
    ACTION_DOWNLOAD = 'DOWNLOAD'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Who did what
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True, index=True)
    action = db.Column(db.String(50), nullable=False, index=True)
    entity_type = db.Column(db.String(50), nullable=False, index=True)  # ExpenseRequest, User, etc.
    entity_id = db.Column(db.Integer, nullable=False, index=True)
    
    # Details
    note = db.Column(db.Text)
    
    # Metadata
    ip_address = db.Column(db.String(45))
    
    # Timestamp - immutable, no onupdate
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    # Relationships
    user = db.relationship('User')
    
    @staticmethod
    def log(user_id, action, entity_type, entity_id, note=None, ip_address=None):
        """Create an audit log entry."""
        log_entry = AuditLog(
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            entity_id=entity_id,
            note=note,
            ip_address=ip_address
        )
        
        db.session.add(log_entry)
        return log_entry
    
    def __repr__(self):
        return f'<AuditLog {self.action} on {self.entity_type}#{self.entity_id} by User#{self.user_id}>'
