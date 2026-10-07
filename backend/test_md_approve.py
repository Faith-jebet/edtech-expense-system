from app import create_app, db
from app.models import User, ExpenseRequest
from app.services.workflow_service import WorkflowService

app = create_app()
with app.app_context():
    md = User.query.filter_by(role='Managing Director').first()
    print("MD:", md.email)
    req = ExpenseRequest.query.filter_by(status='Verified').first()
    if not req:
        print("No verified request found.")
    else:
        print("Request:", req.request_id, req.total_amount_usd)
        success, msg, _ = WorkflowService.approve_request(req, md, "Approved by MD test")
        print("Success:", success, "Msg:", msg)
