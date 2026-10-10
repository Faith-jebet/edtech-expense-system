"""Expense request endpoints."""
from flask import request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError
from app import db
from app.api.v1 import api_v1
from app.models import ExpenseRequest, RequestItem, User, Project, ExpenseCategory, ExchangeRate, Attachment, AuditLog, Payment
from app.schemas.expense_request_schema import (
    ExpenseRequestSchema, ExpenseRequestCreateSchema, 
    ApprovalActionSchema, PaymentExecutionSchema, LedgerPostingSchema
)
from app.services.workflow_service import WorkflowService
from app.services.id_service import IDService
from datetime import datetime, date
from decimal import Decimal
import os
from werkzeug.utils import secure_filename


expense_request_schema = ExpenseRequestSchema()
expense_requests_schema = ExpenseRequestSchema(many=True)
create_schema = ExpenseRequestCreateSchema()
approval_schema = ApprovalActionSchema()
payment_schema = PaymentExecutionSchema()
ledger_schema = LedgerPostingSchema()


def serialize_expense_request(expense_request):
    """Serialize expense request with related data."""
    data = {
        'id': expense_request.id,
        'request_id': expense_request.request_id,
        'requester_id': expense_request.requester_id,
        'requester_name': expense_request.requester.full_name,
        'project_id': expense_request.project_id,
        'project_name': expense_request.project.name,
        'request_date': expense_request.request_date.isoformat(),
        'purpose': expense_request.purpose,
        'business_justification': expense_request.purpose,
        'payee_name': expense_request.payee_name,
        'payment_method': expense_request.payment_method,
        'currency': expense_request.currency,
        'exchange_rate_to_usd': str(expense_request.exchange_rate_to_usd) if expense_request.exchange_rate_to_usd else None,
        'total_amount': str(expense_request.total_amount),
        'total_amount_usd': str(expense_request.total_amount_usd),
        'status': expense_request.status,
        'priority': expense_request.priority,
        'budget_status': expense_request.budget_status,
        'is_split_purchase': expense_request.is_split_purchase,
        'created_at': expense_request.created_at.isoformat() if expense_request.created_at else None,
        'updated_at': expense_request.updated_at.isoformat() if expense_request.updated_at else None,
        'verified_at': expense_request.verified_at.isoformat() if expense_request.verified_at else None,
        'approved_at': expense_request.approved_at.isoformat() if expense_request.approved_at else None,
        'paid_at': expense_request.paid_at.isoformat() if expense_request.paid_at else None,
        'posted_at': expense_request.posted_at.isoformat() if expense_request.posted_at else None,
        'closed_at': expense_request.closed_at.isoformat() if expense_request.closed_at else None,
        'verified_by_id': expense_request.verified_by_id,
        'verified_by_name': expense_request.verified_by.full_name if expense_request.verified_by else None,
        'approved_by_id': expense_request.approved_by_id,
        'approved_by_name': expense_request.approved_by.full_name if expense_request.approved_by else None,
        'paid_by_id': expense_request.payments.order_by(db.desc(Payment.id)).first().paid_by_id if expense_request.payments and expense_request.payments.count() > 0 else expense_request.paid_by_id,
        'paid_by_name': expense_request.payments.order_by(db.desc(Payment.id)).first().paid_by.full_name if expense_request.payments and expense_request.payments.count() > 0 and expense_request.payments.order_by(db.desc(Payment.id)).first().paid_by else (expense_request.paid_by.full_name if expense_request.paid_by else None),
        'payment_reference': ', '.join([p.payment_reference for p in expense_request.payments.all()]) if expense_request.payments and expense_request.payments.count() > 0 else expense_request.payment_reference,
        'actual_amount_paid': str(sum(p.actual_amount_paid for p in expense_request.payments.all())) if expense_request.payments and expense_request.payments.count() > 0 else (str(expense_request.actual_amount_paid) if expense_request.actual_amount_paid else None),
        'posted_by_id': expense_request.payments.order_by(db.desc(Payment.id)).first().posted_by_id if expense_request.payments and expense_request.payments.count() > 0 else expense_request.posted_by_id,
        'posted_by_name': expense_request.payments.order_by(db.desc(Payment.id)).first().posted_by.full_name if expense_request.payments and expense_request.payments.count() > 0 and expense_request.payments.order_by(db.desc(Payment.id)).first().posted_by else (expense_request.posted_by.full_name if expense_request.posted_by else None),
        'ledger_reference': expense_request.payments.order_by(db.desc(Payment.id)).first().ledger_reference if expense_request.payments and expense_request.payments.count() > 0 else expense_request.ledger_reference,
        'closed_by_id': expense_request.closed_by_id,
        'closed_by_name': expense_request.closed_by.full_name if expense_request.closed_by else None,
        'items': [{
            'id': item.id,
            'category_id': item.category_id,
            'category_name': item.category.name if item.category else None,
            'description': item.description,
            'quantity': str(item.quantity),
            'unit_cost': str(item.unit_price),
            'amount': str(item.total_price)
        } for item in expense_request.items],
        'attachments': [{
            'id': att.id,
            'attachment_type': att.attachment_type,
            'filename': att.filename,
            'filesize': att.filesize,
            'mime_type': None,
            'description': None,
            'uploaded_by_id': att.uploaded_by_id,
            'created_at': att.created_at.isoformat(),
            'download_url': f'/api/v1/expense-requests/{expense_request.id}/attachments/{att.id}/download'
        } for att in expense_request.attachments],
        'approvals': [{
            'id': app.id,
            'approver_id': app.approver_id,
            'approver_name': app.approver.full_name if app.approver else None,
            'decision': app.decision,
            'comments': app.comments,
            'created_at': app.created_at.isoformat()
        } for app in expense_request.approvals]
    }
    
    return data


@api_v1.route('/expense-requests', methods=['GET'])
@jwt_required()
def list_expense_requests():
    """
    List expense requests with filters.
    Query params: status, project_id, category_id, requester_id, from_date, to_date, page, per_page
    """
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    query = ExpenseRequest.query
    
    # Filters
    status = request.args.get('status')
    if status:
        query = query.filter_by(status=status)
    
    project_id = request.args.get('project_id', type=int)
    if project_id:
        query = query.filter_by(project_id=project_id)
    
    category_id = request.args.get('category_id', type=int)
    if category_id:
        query = query.filter_by(category_id=category_id)
    
    requester_id = request.args.get('requester_id', type=int)
    if requester_id:
        query = query.filter_by(requester_id=requester_id)
    
    from_date = request.args.get('from_date')
    if from_date:
        query = query.filter(ExpenseRequest.created_at >= datetime.fromisoformat(from_date))
    
    to_date = request.args.get('to_date')
    if to_date:
        query = query.filter(ExpenseRequest.created_at <= datetime.fromisoformat(to_date))
    
    # Role-based visibility
    from app.models import Approval
    if user.role != User.ROLE_ADMIN:
        visibility_conditions = [ExpenseRequest.requester_id == user.id]
        
        if user.role == User.ROLE_ACCOUNTANT:
            visibility_conditions.append(ExpenseRequest.status.in_([
                ExpenseRequest.STATUS_SUBMITTED,
                ExpenseRequest.STATUS_PAID,
                ExpenseRequest.STATUS_POSTED,
                ExpenseRequest.STATUS_CLOSED
            ]))
        elif user.role in [User.ROLE_OPERATION_MANAGER, User.ROLE_MANAGER]:
            visibility_conditions.append(db.and_(
                ExpenseRequest.status == ExpenseRequest.STATUS_VERIFIED,
                ExpenseRequest.total_amount_usd <= 100
            ))
        elif user.role == User.ROLE_DIRECTOR:
            visibility_conditions.append(db.and_(
                ExpenseRequest.status == ExpenseRequest.STATUS_VERIFIED,
                ExpenseRequest.total_amount_usd > 100,
                ExpenseRequest.total_amount_usd <= 500
            ))
        elif user.role == User.ROLE_MD:
            visibility_conditions.append(db.and_(
                ExpenseRequest.status == ExpenseRequest.STATUS_VERIFIED,
                ExpenseRequest.total_amount_usd > 500
            ))
        elif user.role == User.ROLE_PAYING_OFFICER:
            visibility_conditions.append(ExpenseRequest.status.in_([
                ExpenseRequest.STATUS_PARTIALLY_PAID,
                ExpenseRequest.STATUS_PAID,
                ExpenseRequest.STATUS_POSTED,
                ExpenseRequest.STATUS_CLOSED
            ]))
            
        # Also allow viewing if they've approved/verified it
        visibility_conditions.append(ExpenseRequest.approvals.any(Approval.approver_id == user.id))
        
        query = query.filter(db.or_(*visibility_conditions))
    
    # Pagination
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    # Order by created_at descending
    query = query.order_by(ExpenseRequest.created_at.desc())
    
    pagination = query.paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'requests': [serialize_expense_request(req) for req in pagination.items],
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200


@api_v1.route('/expense-requests', methods=['POST'])
@jwt_required()
def create_expense_request():
    """Create a new expense request (draft)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    try:
        data = create_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    # Validate project exists or create new
    if data.get('new_project_name'):
        from datetime import date
        import random
        new_code = f"NEW-{random.randint(1000, 9999)}"
        project = Project(
            code=new_code,
            name=data['new_project_name'],
            budget=0,
            currency='USD',
            start_date=date.today(),
            is_active=True
        )
        db.session.add(project)
        db.session.commit()
        data['project_id'] = project.id
    else:
        project = Project.query.get(data.get('project_id'))
        if not project:
            return jsonify({'error': 'Project not found or new project name required'}), 404
    
    # Validate category exists
    category = ExpenseCategory.query.get(data['category_id'])
    if not category:
        return jsonify({'error': 'Category not found'}), 404
    
    # Get exchange rate
    try:
        exchange_rate = ExchangeRate.get_rate(data['currency'], 'USD')
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    
    # Calculate total amount
    total_amount = sum(Decimal(str(item['quantity'])) * Decimal(str(item['unit_cost'])) 
                      for item in data['items'])
    total_amount_usd = total_amount * Decimal(str(exchange_rate))
    
    # Generate request ID
    request_id = IDService.generate_expense_request_id()
    
    # Create expense request
    expense_request = ExpenseRequest(
        request_id=request_id,
        requester_id=user.id,
        project_id=data['project_id'],
        request_date=datetime.utcnow().date(),
        purpose=data['business_justification'],
        payee_name=data['payee_name'],
        payment_method=data['payment_method'],
        currency=data['currency'],
        exchange_rate_to_usd=Decimal(str(exchange_rate)),
        total_amount=total_amount,
        total_amount_usd=total_amount_usd,
        status=ExpenseRequest.STATUS_DRAFT,
        priority=data['priority'],
        budget_status=data['budget_status']
    )
    
    db.session.add(expense_request)
    db.session.flush()
    
    # Add line items
    for item_data in data['items']:
        item = RequestItem(
            request_id=expense_request.id,
            category_id=data['category_id'],
            description=item_data['description'],
            quantity=Decimal(str(item_data['quantity'])),
            unit_price=Decimal(str(item_data['unit_cost'])),
            total_price=Decimal(str(item_data['quantity'])) * Decimal(str(item_data['unit_cost']))
        )
        db.session.add(item)
    
    db.session.commit()
    
    # Log creation
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_CREATE,
        entity_type='ExpenseRequest',
        entity_id=expense_request.id,
        note=f"Created expense request {expense_request.request_id}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify(serialize_expense_request(expense_request)), 201


@api_v1.route('/expense-requests/<int:id>', methods=['GET'])
@jwt_required()
def get_expense_request(id):
    """Get a specific expense request."""
    expense_request = ExpenseRequest.query.get_or_404(id)
    return jsonify(serialize_expense_request(expense_request)), 200


@api_v1.route('/expense-requests/<int:id>/submit', methods=['POST'])
@jwt_required()
def submit_expense_request(id):
    """Submit a draft request."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    success, message, result = WorkflowService.submit_request(
        expense_request, user, request.remote_addr
    )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/<int:id>/verify', methods=['POST'])
@jwt_required()
def verify_expense_request(id):
    """Verify a submitted request (Accountant)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    try:
        data = approval_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    if data['decision'] == 'Verified':
        success, message, result = WorkflowService.verify_request(
            expense_request, user, 
            comments=data.get('comments'),
            ip_address=request.remote_addr
        )
    else:
        if not data.get('rejection_reason') and not data.get('comments'):
            return jsonify({'error': 'Rejection reason is required'}), 400
        
        reason = data.get('rejection_reason') or data.get('comments')
        success, message, result = WorkflowService.reject_request(
            expense_request, user, reason, request.remote_addr
        )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/<int:id>/approve', methods=['POST'])
@jwt_required()
def approve_expense_request(id):
    """Approve or reject a verified request."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    try:
        data = approval_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    if data['decision'] == 'Approved':
        success, message, result = WorkflowService.approve_request(
            expense_request, user,
            comments=data.get('comments'),
            signature_text=data.get('signature_text'),
            ip_address=request.remote_addr
        )
    else:
        if not data.get('rejection_reason') and not data.get('comments'):
            return jsonify({'error': 'Rejection reason is required'}), 400
        
        reason = data.get('rejection_reason') or data.get('comments')
        success, message, result = WorkflowService.reject_request(
            expense_request, user, reason, request.remote_addr
        )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/my-tasks', methods=['GET'])
@jwt_required()
def get_my_tasks():
    """Get tasks for current user based on their role."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    tasks = {
        'pending_verification': [],
        'pending_approval': [],
        'pending_payment': [],
        'pending_posting': [],
        'my_requests': []
    }
    
    # Accountant: pending verification and posting
    if user.role == User.ROLE_ACCOUNTANT:
        tasks['pending_verification'] = [
            serialize_expense_request(req) 
            for req in ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_SUBMITTED).order_by(ExpenseRequest.created_at.desc()).all()
            if req.requester_id != user.id
        ]
        tasks['pending_posting'] = [
            serialize_expense_request(req)
            for req in ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_PAID).order_by(ExpenseRequest.created_at.desc()).all()
            if req.requester_id != user.id and any(
                attachment.attachment_type in ['Receipt', 'Proof of Payment']
                for attachment in req.attachments
            )
        ]
    
    # Approvers: pending approval within their authority
    if user.role in [User.ROLE_DIRECTOR, User.ROLE_MANAGING_DIRECTOR, User.ROLE_OPERATION_MANAGER, User.ROLE_MANAGER]:
        verified_requests = ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_VERIFIED).order_by(ExpenseRequest.created_at.desc()).all()
        for req in verified_requests:
            # Check if user can approve this request
            can_approve, _ = req.can_transition_to(ExpenseRequest.STATUS_APPROVED, user)
            if can_approve:
                tasks['pending_approval'].append(serialize_expense_request(req))
    
    # Paying Officer: pending payment
    if user.role == User.ROLE_PAYING_OFFICER:
        tasks['pending_payment'] = [
            serialize_expense_request(req)
            for req in ExpenseRequest.query.filter(
                ExpenseRequest.status.in_([ExpenseRequest.STATUS_APPROVED, ExpenseRequest.STATUS_PARTIALLY_PAID])
            ).order_by(ExpenseRequest.created_at.desc()).all()
        ]
    
    # My requests
    tasks['my_requests'] = [
        serialize_expense_request(req)
        for req in ExpenseRequest.query.filter_by(requester_id=user.id).order_by(ExpenseRequest.created_at.desc()).limit(10).all()
    ]
    
    return jsonify(tasks), 200


# Payment and closing endpoints will be in Phase 3


@api_v1.route('/expense-requests/<int:id>/pay', methods=['POST'])
@jwt_required()
def execute_payment(id):
    """Execute payment (Paying Officer)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    try:
        data = payment_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    success, message, payment = WorkflowService.execute_payment(
        expense_request, user,
        payment_reference=data['payment_reference'],
        actual_amount_paid=Decimal(str(data['actual_amount_paid'])),
        payment_date=data['payment_date'],
        payment_notes=data.get('payment_notes'),
        ip_address=request.remote_addr
    )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/<int:id>/attachments', methods=['POST'])
@jwt_required()
def upload_attachment(id):
    """Upload attachment (supporting document or payment proof)."""
    from flask import current_app
    from werkzeug.utils import secure_filename
    import uuid
    
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    attachment_type = request.form.get('attachment_type')
    if not attachment_type:
        return jsonify({'error': 'Attachment type is required'}), 400

    supporting_types = ['Quotation', 'Invoice']
    evidence_types = ['Receipt', 'Proof of Payment', 'Cash Voucher']
    
    if expense_request.status in [ExpenseRequest.STATUS_DRAFT, ExpenseRequest.STATUS_SUBMITTED, ExpenseRequest.STATUS_REJECTED]:
        if user.id != expense_request.requester_id or attachment_type not in supporting_types:
            return jsonify({
                'error': 'Only Quotations and Invoices can be attached as supporting documents'
            }), 403
    elif expense_request.status == ExpenseRequest.STATUS_PAID:
        if user.role != User.ROLE_PAYING_OFFICER or attachment_type not in evidence_types:
            return jsonify({
                'error': 'Only the Paying Officer can attach payment evidence after payment'
            }), 403
    else:
        return jsonify({
            'error': 'Documents can only be attached to a draft or after payment'
        }), 400
    
    description = request.form.get('description', '')
    
    # Validate file extension
    filename = secure_filename(file.filename)
    file_ext = filename.rsplit('.', 1)[1].lower() if '.' in filename else ''
    
    if file_ext not in current_app.config['ALLOWED_EXTENSIONS']:
        return jsonify({'error': f'File type .{file_ext} not allowed'}), 400
        
    if attachment_type in ['Quotation', 'Invoice'] and file_ext not in ['pdf', 'doc', 'docx']:
        return jsonify({'error': f'Quotations and Invoices must be PDF or Word documents. Image files ({file_ext}) cannot be processed.'}), 400
    
    # Check file size
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    
    if file_size > current_app.config['MAX_UPLOAD_SIZE']:
        return jsonify({'error': 'File too large (max 10MB)'}), 400
        
    # Content-based validation for Quotations and Invoices
    if attachment_type in ['Quotation', 'Invoice']:
        text_content = ""
        try:
            if file_ext == 'pdf':
                import PyPDF2
                reader = PyPDF2.PdfReader(file)
                for page in reader.pages:
                    text_content += page.extract_text().lower()
            elif file_ext in ['doc', 'docx']:
                import docx
                doc = docx.Document(file)
                for para in doc.paragraphs:
                    text_content += para.text.lower()
                    
            file.seek(0) # Reset pointer
            
            # Check for keywords
            keywords = ['quote', 'quotation', 'invoice', 'bill', 'receipt', 'estimate', 'amount', 'total']
            found_keywords = sum(1 for kw in keywords if kw in text_content)
            
            if found_keywords < 2:
                return jsonify({'error': 'The uploaded document does not appear to be a valid invoice or quotation. Please upload an official financial document.'}), 400
                
        except Exception as e:
            file.seek(0)
            return jsonify({'error': f'Could not read document contents to verify validity: {str(e)}'}), 400
    
    # Generate unique filename
    unique_filename = f"{uuid.uuid4().hex}_{filename}"
    
    # Organize by year/month for easier management
    upload_dir = os.path.join(
        current_app.config['UPLOAD_FOLDER'],
        datetime.utcnow().strftime('%Y'),
        datetime.utcnow().strftime('%m')
    )
    os.makedirs(upload_dir, exist_ok=True)
    
    filepath = os.path.join(upload_dir, unique_filename)
    file.save(filepath)
    
    # Create attachment record
    attachment = Attachment(
        request_id=expense_request.id,
        attachment_type=attachment_type,
        filename=filename,
        filepath=filepath,
        filesize=file_size,
        uploaded_by_id=user.id,
    )
    db.session.add(attachment)
    
    # If this is payment proof, update payment record and transition status
    if attachment_type in ['Receipt', 'Proof of Payment'] and expense_request.status in [ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_PARTIALLY_PAID]:
        success, message, result = WorkflowService.attach_payment_proof(
            expense_request, user, attachment, request.remote_addr
        )
        if not success:
            db.session.rollback()
            os.remove(filepath)
            return jsonify({'error': message}), 400
    
    db.session.commit()
    
    # Log upload
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_UPLOAD,
        entity_type='Attachment',
        entity_id=attachment.id,
        note=f"Uploaded {attachment_type}: {filename}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify({
        'message': 'File uploaded successfully',
        'attachment': {
            'id': attachment.id,
            'filename': attachment.filename,
            'attachment_type': attachment.attachment_type,
            'filesize': attachment.filesize,
            'created_at': attachment.created_at.isoformat()
        }
    }), 201


@api_v1.route('/expense-requests/<int:request_id>/attachments/<int:attachment_id>/download', methods=['GET'])
@jwt_required()
def download_attachment(request_id, attachment_id):
    """Download attachment (authenticated users only)."""
    expense_request = ExpenseRequest.query.get_or_404(request_id)
    attachment = Attachment.query.filter_by(
        id=attachment_id,
        request_id=request_id
    ).first_or_404()
    
    if not os.path.exists(attachment.filepath):
        return jsonify({'error': 'File not found'}), 404
    
    # Log download
    current_user_id = get_jwt_identity()
    AuditLog.log(
        user_id=current_user_id,
        action=AuditLog.ACTION_DOWNLOAD,
        entity_type='Attachment',
        entity_id=attachment.id,
        note=f"Downloaded {attachment.filename}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return send_file(
        attachment.filepath,
        as_attachment=True,
        download_name=attachment.filename,
        mimetype='application/octet-stream'
    )


@api_v1.route('/expense-requests/<int:id>/post', methods=['POST'])
@jwt_required()
def post_to_ledger(id):
    """Post to ledger (Accountant)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    try:
        data = ledger_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    success, message, result = WorkflowService.post_to_ledger(
        expense_request, user,
        ledger_reference=data['ledger_reference'],
        posting_notes=data.get('posting_notes'),
        ip_address=request.remote_addr
    )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/<int:id>/close', methods=['POST'])
@jwt_required()
def close_request(id):
    """Close a posted request (Accountant)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    success, message, result = WorkflowService.close_request(
        expense_request, user, request.remote_addr
    )
    
    if not success:
        return jsonify({'error': message}), 400
    
    return jsonify({
        'message': message,
        'request': serialize_expense_request(expense_request)
    }), 200


@api_v1.route('/expense-requests/<int:id>/cash-voucher', methods=['GET'])
@jwt_required()
def generate_cash_voucher(id):
    """Generate printable cash voucher PDF."""
    from reportlab.lib.pagesizes import letter
    from reportlab.lib.units import inch
    from reportlab.pdfgen import canvas
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.platypus import Paragraph
    from io import BytesIO
    
    expense_request = ExpenseRequest.query.get_or_404(id)
    
    if expense_request.payment_method != 'Cash':
        return jsonify({'error': 'Cash voucher only available for cash payments'}), 400
    
    # Create PDF in memory
    buffer = BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter
    
    # Title
    c.setFont("Helvetica-Bold", 16)
    c.drawString(1*inch, height - 1*inch, "CASH VOUCHER")
    
    # Request details
    c.setFont("Helvetica", 11)
    y = height - 1.5*inch
    
    c.drawString(1*inch, y, f"Request ID: {expense_request.request_id}")
    y -= 0.25*inch
    c.drawString(1*inch, y, f"Date: {datetime.utcnow().strftime('%Y-%m-%d')}")
    y -= 0.25*inch
    c.drawString(1*inch, y, f"Payee: {expense_request.payee_name}")
    y -= 0.25*inch
    c.drawString(1*inch, y, f"Amount: {expense_request.total_amount} {expense_request.currency}")
    y -= 0.5*inch
    
    # Line items
    c.setFont("Helvetica-Bold", 11)
    c.drawString(1*inch, y, "Description:")
    y -= 0.25*inch
    
    c.setFont("Helvetica", 10)
    for item in expense_request.items:
        c.drawString(1.25*inch, y, f"• {item.description}")
        y -= 0.2*inch
    
    y -= 0.5*inch
    
    # Signature blocks
    c.setFont("Helvetica-Bold", 10)
    c.drawString(1*inch, y, "Received by:")
    c.drawString(4.5*inch, y, "Authorized by:")
    
    y -= 0.5*inch
    c.line(1*inch, y, 3.5*inch, y)
    c.line(4.5*inch, y, 7*inch, y)
    
    y -= 0.2*inch
    c.setFont("Helvetica", 9)
    c.drawString(1*inch, y, "Signature & Date")
    c.drawString(4.5*inch, y, "Signature & Date")
    
    # Footer
    c.setFont("Helvetica-Oblique", 8)
    c.drawString(1*inch, 0.75*inch, 
                f"Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')} | Milestone EdTech Solutions Ltd")
    
    c.showPage()
    c.save()
    
    buffer.seek(0)
    
    return send_file(
        buffer,
        as_attachment=True,
        download_name=f"cash_voucher_{expense_request.request_id}.pdf",
        mimetype='application/pdf'
    )
