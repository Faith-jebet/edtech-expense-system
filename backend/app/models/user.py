"""User model."""
from app import db
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash


class User(db.Model):
    """User model with role-based access control."""
    
    __tablename__ = 'users'
    
    # Role constants  
    ROLE_OPERATION_MANAGER = 'Operation Manager'
    ROLE_MANAGER = 'Manager'  # Legacy role retained for existing accounts.
    ROLE_ACCOUNTANT = 'Accountant'
    ROLE_DIRECTOR = 'Director'
    ROLE_MANAGING_DIRECTOR = 'Managing Director'
    ROLE_MD = ROLE_MANAGING_DIRECTOR
    ROLE_PAYING_OFFICER = 'Paying Officer'
    ROLE_ADMIN = 'Admin'
    
    ROLES = [
        ROLE_OPERATION_MANAGER,
        ROLE_MANAGER,
        ROLE_ACCOUNTANT,
        ROLE_DIRECTOR,
        ROLE_MANAGING_DIRECTOR,
        ROLE_PAYING_OFFICER,
        ROLE_ADMIN
    ]
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(50), nullable=False, index=True)
    is_active = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    submitted_requests = db.relationship('ExpenseRequest', foreign_keys='ExpenseRequest.requester_id', 
                                        back_populates='requester', lazy='dynamic')
    approvals_given = db.relationship('Approval', foreign_keys='Approval.approver_id',
                                     back_populates='approver', lazy='dynamic')
    payments_made = db.relationship('Payment', foreign_keys='Payment.paid_by_id',
                                   back_populates='paid_by', lazy='dynamic')
    
    def set_password(self, password):
        """Hash and set password."""
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        """Verify password."""
        return check_password_hash(self.password_hash, password)
    
    def can_approve(self, amount_usd):
        """Check if user can approve amount based on role and limits."""
        if self.role in (self.ROLE_OPERATION_MANAGER, self.ROLE_MANAGER):
            return amount_usd <= 100
        elif self.role == self.ROLE_DIRECTOR:
            return 100 < amount_usd <= 500
        elif self.role == self.ROLE_MANAGING_DIRECTOR:
            return amount_usd > 500
        return False
    
    def can_verify(self):
        """Check if user can verify requests."""
        return self.role == self.ROLE_ACCOUNTANT
    
    def can_pay(self):
        """Check if user can execute payments."""
        return self.role == self.ROLE_PAYING_OFFICER
    
    def can_post(self):
        """Check if user can post to ledger."""
        return self.role == self.ROLE_ACCOUNTANT
    
    def is_admin(self):
        """Check if user is admin."""
        return self.role == self.ROLE_ADMIN
    
    def __repr__(self):
        return f'<User {self.email} ({self.role})>'
