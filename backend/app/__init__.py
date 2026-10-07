"""Application factory and extensions initialization."""
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_mail import Mail
from flask_cors import CORS
from apscheduler.schedulers.background import BackgroundScheduler
import logging
import os

# Initialize extensions
db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)
mail = Mail()
scheduler = BackgroundScheduler()


def create_app(config_name='default'):
    """Create and configure the Flask application."""
    app = Flask(__name__)
    
    # Load configuration
    from config import config
    app.config.from_object(config[config_name])
    
    # Ensure upload folder exists
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
    os.makedirs(app.config['BACKUP_PATH'], exist_ok=True)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    limiter.init_app(app)
    mail.init_app(app)
    
    # Configure CORS
    CORS(app, 
         origins=[app.config['FRONTEND_URL']],
         supports_credentials=True,
         expose_headers=['X-CSRF-TOKEN'])
    
    # Configure logging (enable in debug mode too for troubleshooting)
    logging.basicConfig(
        level=logging.DEBUG if app.debug else logging.INFO,
        format='%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    )
    
    # Add error handler to log all exceptions
    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(f'Unhandled exception: {e}', exc_info=True)
        # Re-raise so Flask's default handler can also process it
        raise e
    
    # Register blueprints
    from app.api.v1 import api_v1
    app.register_blueprint(api_v1, url_prefix='/api/v1')
    
    # JWT handlers
    from app.api.v1.auth import configure_jwt_handlers
    configure_jwt_handlers(jwt)
    
    # Start scheduler for reminders and overdue checks
    if not app.testing and not scheduler.running:
        from app.tasks import configure_scheduler
        configure_scheduler(scheduler, app)
        scheduler.start()
    
    # Health check route
    @app.route('/health')
    def health():
        return {'status': 'healthy'}, 200
    
    return app
