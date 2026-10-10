"""Settings service for system configuration."""
from app.models import Setting
from flask import current_app


class SettingsService:
    """Manage system settings with fallback to environment config."""
    
    @staticmethod
    def get(key, default=None):
        """Get setting value, falling back to environment config or default."""
        # Try database first
        value = Setting.get(key)
        if value is not None:
            return value
        
        # Fall back to app config
        config_key = key.upper()
        if hasattr(current_app.config, config_key):
            return current_app.config[config_key]
        
        # Return default
        return default
    
    @staticmethod
    def get_approval_sla_days():
        """Get approval SLA in days."""
        return SettingsService.get('approval_sla_days', 
                                   current_app.config.get('DEFAULT_APPROVAL_SLA_DAYS', 2))
    
    @staticmethod
    def get_payment_sla_days():
        """Get payment SLA in days."""
        return SettingsService.get('payment_sla_days',
                                   current_app.config.get('DEFAULT_PAYMENT_SLA_DAYS', 3))
    
    @staticmethod
    def get_receipt_sla_days():
        """Get receipt upload SLA in days."""
        return SettingsService.get('receipt_sla_days',
                                   current_app.config.get('DEFAULT_RECEIPT_SLA_DAYS', 5))
    
    @staticmethod
    def get_advance_retirement_days():
        """Get default advance retirement period in days."""
        return SettingsService.get('advance_retirement_days',
                                   current_app.config.get('DEFAULT_ADVANCE_RETIREMENT_DAYS', 14))
    
    @staticmethod
    def get_payment_tolerance():
        """Get payment tolerance percentage."""
        return SettingsService.get('payment_tolerance_percent',
                                   current_app.config.get('PAYMENT_TOLERANCE_PERCENT', 2.0))
    
    @staticmethod
    def get_approval_limits():
        """Get approval limits configuration."""
        limits = Setting.get('approval_limits')
        if limits:
            return limits
        
        # Default limits
        return {
            'band_1': {'max': 100, 'roles': ['Operation Manager']},
            'band_2': {'max': 500, 'roles': ['Director']},
            'band_3': {'max': None, 'roles': ['Managing Director']}
        }
