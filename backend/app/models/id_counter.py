"""ID counter model for generating unique request IDs."""
from app import db
from datetime import datetime


class IDCounter(db.Model):
    """Counter for generating unique request IDs per year."""
    
    __tablename__ = 'id_counters'
    
    id = db.Column(db.Integer, primary_key=True)
    counter_type = db.Column(db.String(50), nullable=False, index=True)
    year = db.Column(db.Integer, nullable=False, index=True)
    current_value = db.Column(db.Integer, default=0, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    @staticmethod
    def get_next_id(year=None):
        """
        Get the next request ID for a given year.
        Format: ME-EXP-YYYY-####
        Uses SELECT FOR UPDATE to ensure uniqueness under concurrency.
        """
        if year is None:
            year = datetime.utcnow().year
        
        counter_type = 'expense_request'
        
        # Must be called within a transaction
        counter = IDCounter.query.filter_by(counter_type=counter_type, year=year).with_for_update().first()
        
        if not counter:
            counter = IDCounter(counter_type=counter_type, year=year, current_value=0)
            db.session.add(counter)
            db.session.flush()
        
        counter.current_value += 1
        next_number = counter.current_value
        
        return f"ME-EXP-{year}-{next_number:04d}"
    
    def __repr__(self):
        return f'<IDCounter {self.counter_type} {self.year}: {self.current_value}>'
