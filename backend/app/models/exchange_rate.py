"""Exchange rate model."""
from app import db
from datetime import datetime


class ExchangeRate(db.Model):
    """Exchange rates for currency conversion."""
    
    __tablename__ = 'exchange_rates'
    
    id = db.Column(db.Integer, primary_key=True)
    from_currency = db.Column(db.String(10), nullable=False, index=True)
    to_currency = db.Column(db.String(10), default='USD', nullable=False)
    rate = db.Column(db.DECIMAL(10, 6), nullable=False)
    effective_date = db.Column(db.Date, nullable=False, index=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # The database schema already indexes currency and effective date.
    
    @staticmethod
    def get_rate(from_currency, to_currency='USD', as_of_date=None):
        """Get exchange rate for a currency pair as of a specific date."""
        if from_currency == to_currency:
            return 1.0
        
        if as_of_date is None:
            as_of_date = datetime.utcnow().date()
        
        rate = ExchangeRate.query.filter(
            ExchangeRate.from_currency == from_currency,
            ExchangeRate.to_currency == to_currency,
            ExchangeRate.effective_date <= as_of_date
        ).order_by(ExchangeRate.effective_date.desc()).first()
        
        if rate:
            return float(rate.rate)
        
        # If no rate found, raise error
        raise ValueError(f"No exchange rate found for {from_currency} to {to_currency} as of {as_of_date}")
    
    def __repr__(self):
        return f'<ExchangeRate {self.from_currency}/{self.to_currency}: {self.rate} ({self.effective_date})>'
