"""Background tasks for reminders and overdue checks."""
from app import db
from app.models import ExpenseRequest, Advance
from app.services.notification_service import NotificationService
from datetime import datetime
import logging

logger = logging.getLogger(__name__)


def configure_scheduler(scheduler, app):
    """Configure scheduled tasks."""
    
    @scheduler.scheduled_job('interval', hours=6, id='check_overdue_approvals')
    def check_overdue_approvals():
        """Check for overdue approvals and send reminders."""
        with app.app_context():
            try:
                now = datetime.utcnow()
                
                # Find requests with overdue approvals
                overdue_requests = []
                
                for request in overdue_requests:
                    logger.info(f"Overdue approval: {request.request_id}")
                    NotificationService.notify_overdue_approval(request)
                
                logger.info(f"Checked overdue approvals: {len(overdue_requests)} found")
            except Exception as e:
                logger.error(f"Error checking overdue approvals: {str(e)}")
    
    @scheduler.scheduled_job('interval', hours=6, id='check_overdue_payments')
    def check_overdue_payments():
        """Check for overdue payments and send reminders."""
        with app.app_context():
            try:
                now = datetime.utcnow()
                
                # Find requests with overdue payments
                overdue_requests = []
                
                for request in overdue_requests:
                    logger.info(f"Overdue payment: {request.request_id}")
                    # NotificationService.notify_overdue_payment(request)
                
                logger.info(f"Checked overdue payments: {len(overdue_requests)} found")
            except Exception as e:
                logger.error(f"Error checking overdue payments: {str(e)}")
    
    @scheduler.scheduled_job('interval', hours=6, id='check_overdue_receipts')
    def check_overdue_receipts():
        """Check for overdue receipt uploads and send reminders."""
        with app.app_context():
            try:
                now = datetime.utcnow()
                
                # Find requests with overdue receipt uploads
                overdue_requests = []
                
                for request in overdue_requests:
                    logger.info(f"Overdue receipt: {request.request_id}")
                    NotificationService.notify_receipt_required(request)
                
                logger.info(f"Checked overdue receipts: {len(overdue_requests)} found")
            except Exception as e:
                logger.error(f"Error checking overdue receipts: {str(e)}")
    
    @scheduler.scheduled_job('interval', hours=12, id='check_overdue_advances')
    def check_overdue_advances():
        """Check for overdue advance retirements and send reminders."""
        with app.app_context():
            try:
                today = datetime.utcnow().date()
                
                # Find overdue advances
                overdue_advances = Advance.query.filter(
                    Advance.is_retired == False,
                    Advance.retirement_deadline < today
                ).all()
                
                for advance in overdue_advances:
                    logger.info(f"Overdue advance: {advance.request.request_id}")
                    NotificationService.notify_overdue_advance(advance)
                    
                    # Update reminder tracking
                    advance.last_reminder_sent = datetime.utcnow()
                    advance.reminder_count += 1
                
                db.session.commit()
                logger.info(f"Checked overdue advances: {len(overdue_advances)} found")
            except Exception as e:
                logger.error(f"Error checking overdue advances: {str(e)}")
                db.session.rollback()
    
    logger.info("Scheduler configured with reminder tasks")
