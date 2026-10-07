from app import create_app, db
from app.models import User, ExpenseRequest
from app.services.workflow_service import WorkflowService

app = create_app()
with app.app_context():
    acc = User.query.filter_by(role='Accountant').first()
    print("Accountant:", acc.email)
    req = ExpenseRequest.query.filter_by(status='Submitted').first()
    if not req:
        print("No submitted request found.")
    else:
        print("Request:", req.request_id, req.total_amount_usd, "Attachments:", req.attachments.count())
        success, msg, _ = WorkflowService.verify_request(req, acc, "127.0.0.1")
        print("Success:", success, "Msg:", msg)
