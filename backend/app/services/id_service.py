"""Service for generating unique request IDs."""
from app import db
from app.models import IDCounter
from datetime import datetime


class IDService:
    """Generate unique request IDs with concurrency safety."""
    
    @staticmethod
    def generate_expense_request_id(year=None):
        """
        Generate next expense request ID.
        Format: ME-EXP-YYYY-####
        Thread-safe via SELECT FOR UPDATE.
        """
        if year is None:
            year = datetime.utcnow().year
        
        # Must be called within a transaction
        try:
            request_id = IDCounter.get_next_id(year)
            return request_id
        except Exception as e:
            db.session.rollback()
            raise ValueError(f"Failed to generate request ID: {str(e)}")
    
    @staticmethod
    def generate_income_receipt_id(year=None):
        """
        Generate next income receipt ID.
        Format: ME-REC-YYYY-####
        Similar logic, different prefix.
        """
        if year is None:
            year = datetime.utcnow().year
        
        # For now, reuse the counter logic - in production might want separate table
        base_id = IDCounter.get_next_id(year)
        return base_id.replace('EXP', 'REC')
