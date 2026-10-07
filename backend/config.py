"""Application configuration."""
import os
from datetime import timedelta
from dotenv import load_dotenv
from urllib.parse import quote_plus

load_dotenv()


class Config:
    """Base configuration."""
    
    # Flask
    SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    
    # Database
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = os.getenv('DB_PORT', '3306')
    DB_NAME = os.getenv('DB_NAME', 'edtech_expense_control')
    DB_USER = os.getenv('DB_USER', 'expense_app_user')
    DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
    
    # URL-encode password to handle special characters like @ 
    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://{DB_USER}:{quote_plus(DB_PASSWORD)}@"
        f"{DB_HOST}:{DB_PORT}/{DB_NAME}?charset=utf8mb4"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_pre_ping': True,
        'pool_recycle': 3600,
        'pool_size': 10,
        'max_overflow': 20
    }
    
    # JWT
    JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(seconds=int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', 900)))
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(seconds=int(os.getenv('JWT_REFRESH_TOKEN_EXPIRES', 2592000)))
    JWT_TOKEN_LOCATION = ['headers', 'cookies']
    JWT_COOKIE_SECURE = False  # Set to True in production with HTTPS
    JWT_COOKIE_CSRF_PROTECT = True
    JWT_COOKIE_SAMESITE = 'Lax'
    JWT_REFRESH_COOKIE_PATH = '/api/v1/auth/refresh'
    
    # Email
    MAIL_SERVER = os.getenv('MAIL_SERVER', 'smtp.gmail.com')
    MAIL_PORT = int(os.getenv('MAIL_PORT', 587))
    MAIL_USE_TLS = os.getenv('MAIL_USE_TLS', 'True').lower() == 'true'
    MAIL_USERNAME = os.getenv('MAIL_USERNAME')
    MAIL_PASSWORD = os.getenv('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.getenv('MAIL_DEFAULT_SENDER', 'noreply@milestonetech.com')
    
    # File Upload
    UPLOAD_FOLDER = os.path.abspath(os.getenv('UPLOAD_FOLDER', 'uploads'))
    MAX_UPLOAD_SIZE = int(os.getenv('MAX_UPLOAD_SIZE', 10485760))  # 10MB
    ALLOWED_EXTENSIONS = set(os.getenv('ALLOWED_EXTENSIONS', 'pdf,png,jpg,jpeg,doc,docx,xls,xlsx').split(','))
    
    # Application
    FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:5173')
    BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:5000')
    TIMEZONE = os.getenv('TIMEZONE', 'Africa/Nairobi')
    
    # Security
    RATE_LIMIT_STORAGE_URL = os.getenv('RATE_LIMIT_STORAGE_URL', 'memory://')
    SESSION_TIMEOUT_MINUTES = int(os.getenv('SESSION_TIMEOUT_MINUTES', 60))
    
    # Approval defaults
    DEFAULT_APPROVAL_SLA_DAYS = int(os.getenv('DEFAULT_APPROVAL_SLA_DAYS', 2))
    DEFAULT_PAYMENT_SLA_DAYS = int(os.getenv('DEFAULT_PAYMENT_SLA_DAYS', 3))
    DEFAULT_RECEIPT_SLA_DAYS = int(os.getenv('DEFAULT_RECEIPT_SLA_DAYS', 5))
    DEFAULT_ADVANCE_RETIREMENT_DAYS = int(os.getenv('DEFAULT_ADVANCE_RETIREMENT_DAYS', 14))
    PAYMENT_TOLERANCE_PERCENT = float(os.getenv('PAYMENT_TOLERANCE_PERCENT', 2.0))
    
    # Virus scanning
    ENABLE_VIRUS_SCAN = os.getenv('ENABLE_VIRUS_SCAN', 'False').lower() == 'true'
    VIRUS_SCAN_COMMAND = os.getenv('VIRUS_SCAN_COMMAND', '')
    
    # Backup
    BACKUP_PATH = os.path.abspath(os.getenv('BACKUP_PATH', 'backups'))
    BACKUP_RETENTION_DAYS = int(os.getenv('BACKUP_RETENTION_DAYS', 30))


class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    TESTING = False


class TestingConfig(Config):
    """Testing configuration."""
    TESTING = True
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    SQLALCHEMY_ENGINE_OPTIONS = {}
    JWT_COOKIE_CSRF_PROTECT = False


class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    TESTING = False
    JWT_COOKIE_SECURE = True


config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
