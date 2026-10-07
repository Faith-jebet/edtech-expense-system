"""System settings model."""
from app import db
from datetime import datetime


class Setting(db.Model):
    """System-wide configuration settings."""
    
    __tablename__ = 'settings'
    
    id = db.Column(db.Integer, primary_key=True)
    key = db.Column('key_name', db.String(100), unique=True, nullable=False, index=True)
    value = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    @staticmethod
    def get(key, default=None):
        """Get setting value by key."""
        setting = Setting.query.filter_by(key=key).first()
        if not setting:
            return default
        
        if isinstance(default, bool):
            return setting.value.lower() in ('true', '1', 'yes')
        if isinstance(default, int):
            return int(setting.value)
        if isinstance(default, float):
            return float(setting.value)
        return setting.value
    
    @staticmethod
    def set(key, value, value_type='string', description=None, category=None, user_id=None):
        """Set or update a setting."""
        setting = Setting.query.filter_by(key=key).first()
        value_str = str(value)
        
        if setting:
            setting.value = value_str
            if description:
                setting.description = description
        else:
            setting = Setting(
                key=key,
                value=value_str,
                description=description
            )
            db.session.add(setting)
        
        return setting
    
    def __repr__(self):
        return f'<Setting {self.key}: {self.value}>'
