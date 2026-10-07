"""Reconciliation endpoints."""
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError
from app import db
from app.api.v1 import api_v1
from app.models import Reconciliation, ReconciliationItem, User, AuditLog, ExpenseRequest, IncomeReceipt
from app.schemas.reconciliation_schema import (
    ReconciliationSchema, ReconciliationCreateSchema, ReconciliationUpdateSchema
)
from datetime import datetime
from decimal import Decimal
import csv
import io


reconciliation_schema = ReconciliationSchema()
reconciliations_schema = ReconciliationSchema(many=True)
create_schema = ReconciliationCreateSchema()
update_schema = ReconciliationUpdateSchema()


@api_v1.route('/reconciliations', methods=['GET'])
@jwt_required()
def list_reconciliations():
    """List reconciliations with filters."""
    account_type = request.args.get('account_type')
    status = request.args.get('status')
    
    query = Reconciliation.query
    
    if account_type:
        query = query.filter_by(account_type=account_type)
    
    if status:
        query = query.filter_by(status=status)
    
    # Order by period_end descending
    query = query.order_by(Reconciliation.period_end.desc())
    
    reconciliations = query.all()
    
    return jsonify({
        'reconciliations': [{
            'id': r.id,
            'account_type': r.account_type,
            'account_name': r.account_name,
            'period_start': r.period_start.isoformat(),
            'period_end': r.period_end.isoformat(),
            'account_number': r.account_number,
            'opening_balance': str(r.opening_balance),
            'system_closing_balance': str(r.system_closing_balance),
            'actual_closing_balance': str(r.actual_closing_balance),
            'difference': str(r.difference),
            'status': r.status,
            'has_unexplained_difference': r.has_unexplained_difference,
            'prepared_by_name': r.prepared_by.full_name,
            'reviewed_by_name': r.reviewed_by.full_name if r.reviewed_by else None,
        } for r in reconciliations]
    }), 200


@api_v1.route('/reconciliations', methods=['POST'])
@jwt_required()
def create_reconciliation():
    """Create a new reconciliation."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can create reconciliations'}), 403
    
    try:
        data = create_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    # Calculate difference
    difference = Decimal(str(data['actual_closing_balance'])) - Decimal(str(data['system_closing_balance']))
    
    reconciliation = Reconciliation(
        account_type=data['account_type'],
        account_name=data['account_name'],
        account_number=data.get('account_number'),
        period_start=data['period_start'],
        period_end=data['period_end'],
        opening_balance=Decimal(str(data['opening_balance'])),
        system_closing_balance=Decimal(str(data['system_closing_balance'])),
        actual_closing_balance=Decimal(str(data['actual_closing_balance'])),
        difference=difference,
        status=Reconciliation.STATUS_OPEN,
        prepared_by_id=user.id
    )
    
    db.session.add(reconciliation)
    db.session.commit()
    
    # Log creation
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_CREATE,
        entity_type='Reconciliation',
        entity_id=reconciliation.id,
        note=f"Created reconciliation for {reconciliation.account_name}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify(reconciliation_schema.dump(reconciliation)), 201


@api_v1.route('/reconciliations/<int:id>', methods=['GET'])
@jwt_required()
def get_reconciliation(id):
    """Get a specific reconciliation."""
    reconciliation = Reconciliation.query.get_or_404(id)
    
    data = reconciliation_schema.dump(reconciliation)
    data['items'] = [{
        'id': item.id,
        'transaction_date': item.transaction_date.isoformat(),
        'description': item.description,
        'reference': item.reference,
        'debit': str(item.debit),
        'credit': str(item.credit),
        'matched': item.matched
    } for item in reconciliation.items]
    
    return jsonify(data), 200


@api_v1.route('/reconciliations/<int:id>', methods=['PATCH'])
@jwt_required()
def update_reconciliation(id):
    """Update reconciliation (add explanation or change status)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can update reconciliations'}), 403
    
    reconciliation = Reconciliation.query.get_or_404(id)
    
    try:
        data = update_schema.load(request.get_json())
    except ValidationError as err:
        return jsonify({'error': 'Validation error', 'messages': err.messages}), 400
    
    if 'explanation' in data:
        reconciliation.explanation = data['explanation']
    
    if 'status' in data:
        reconciliation.status = data['status']
    
    db.session.commit()
    
    # Log update
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_UPDATE,
        entity_type='Reconciliation',
        entity_id=reconciliation.id,
        note=f"Updated reconciliation: {data}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify(reconciliation_schema.dump(reconciliation)), 200


@api_v1.route('/reconciliations/<int:id>/review', methods=['POST'])
@jwt_required()
def review_reconciliation(id):
    """Review a reconciliation (separation of duties: reviewer != preparer)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can review reconciliations'}), 403
    
    reconciliation = Reconciliation.query.get_or_404(id)
    
    if reconciliation.prepared_by_id == user.id:
        return jsonify({'error': 'Separation of duties: you cannot review your own reconciliation'}), 400
    
    reconciliation.reviewed_by_id = user.id
    reconciliation.reviewed_at = datetime.utcnow()
    
    db.session.commit()
    
    # Log review
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_UPDATE,
        entity_type='Reconciliation',
        entity_id=reconciliation.id,
        note=f"Reviewed reconciliation",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify({
        'message': 'Reconciliation reviewed successfully',
        'reconciliation': reconciliation_schema.dump(reconciliation)
    }), 200


@api_v1.route('/reconciliations/<int:id>/import-csv', methods=['POST'])
@jwt_required()
def import_reconciliation_csv(id):
    """Import reconciliation items from CSV statement."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can import statements'}), 403
    
    reconciliation = Reconciliation.query.get_or_404(id)
    
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '' or not file.filename.endswith('.csv'):
        return jsonify({'error': 'Please provide a CSV file'}), 400
    
    try:
        # Read CSV
        stream = io.StringIO(file.stream.read().decode('UTF8'), newline=None)
        csv_reader = csv.DictReader(stream)
        
        imported_count = 0
        
        # Expected columns: date, description, reference, debit, credit
        for row in csv_reader:
            # Parse transaction
            transaction_date = datetime.strptime(row.get('date', ''), '%Y-%m-%d').date()
            description = row.get('description', '')
            reference = row.get('reference', '')
            debit = Decimal(row.get('debit', '0') or '0')
            credit = Decimal(row.get('credit', '0') or '0')
            
            # Create item
            item = ReconciliationItem(
                reconciliation_id=reconciliation.id,
                transaction_date=transaction_date,
                description=description,
                reference=reference,
                debit=debit,
                credit=credit,
                matched=False
            )
            db.session.add(item)
            imported_count += 1
        
        db.session.commit()
        
        # Log import
        AuditLog.log(
            user_id=user.id,
            action=AuditLog.ACTION_UPLOAD,
            entity_type='Reconciliation',
            entity_id=reconciliation.id,
            note=f"Imported {imported_count} items from CSV",
            ip_address=request.remote_addr
        )
        db.session.commit()
        
        return jsonify({
            'message': f'Successfully imported {imported_count} transactions',
            'count': imported_count
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Failed to import CSV: {str(e)}'}), 400


@api_v1.route('/reconciliations/exceptions', methods=['GET'])
@jwt_required()
def get_reconciliation_exceptions():
    """Get all unreconciled differences and exceptions."""
    # Unreconciled differences
    unreconciled = Reconciliation.query.filter(
        Reconciliation.status == Reconciliation.STATUS_OPEN,
        Reconciliation.difference != 0
    ).all()
    
    # Overdue advances
    from app.models import Advance
    overdue_advances = Advance.query.filter(
        Advance.is_retired == False,
        Advance.retirement_deadline < datetime.utcnow().date()
    ).all()
    
    # Missing receipts (paid but no proof attached)
    paid_requests = ExpenseRequest.query.filter(
        ExpenseRequest.status == ExpenseRequest.STATUS_PAID
    ).all()
    
    missing_receipts = [req for req in paid_requests if not any(att.attachment_type in ['Receipt', 'Proof of Payment'] for att in req.attachments)]
    
    return jsonify({
        'unreconciled_differences': [{
            'id': r.id,
            'account_name': r.account_name,
            'account_type': r.account_type,
            'period_end': r.period_end.isoformat(),
            'difference': str(r.difference),
            'prepared_by': r.prepared_by.full_name
        } for r in unreconciled],
        'overdue_advances': [{
            'id': adv.id,
            'request_id': adv.request.request_id,
            'requester': adv.request.requester.full_name,
            'amount': str(adv.advance_amount),
            'deadline': adv.retirement_deadline.isoformat(),
            'days_overdue': adv.days_overdue
        } for adv in overdue_advances],
        'missing_receipts': [{
            'id': req.id,
            'request_id': req.request_id,
            'payee': req.payee_name,
            'amount': str(req.total_amount),
            'paid_at': req.paid_at.isoformat() if req.paid_at else None
        } for req in missing_receipts]
    }), 200
