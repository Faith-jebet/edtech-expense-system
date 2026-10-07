"""Income receipts endpoints."""
from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError
from app import db
from app.api.v1 import api_v1
from app.models import IncomeReceipt, User, Project, ExchangeRate, AuditLog
from app.schemas.reconciliation_schema import IncomeReceiptSchema
from app.services.id_service import IDService
from datetime import datetime
from decimal import Decimal


income_receipt_schema = IncomeReceiptSchema()
income_receipts_schema = IncomeReceiptSchema(many=True)


@api_v1.route('/income-receipts', methods=['GET'])
@jwt_required()
def list_income_receipts():
    """List income receipts with filters."""
    project_id = request.args.get('project_id', type=int)
    from_date = request.args.get('from_date')
    to_date = request.args.get('to_date')
    
    query = IncomeReceipt.query
    
    if project_id:
        query = query.filter_by(project_id=project_id)
    
    if from_date:
        query = query.filter(IncomeReceipt.receipt_date >= datetime.fromisoformat(from_date).date())
    
    if to_date:
        query = query.filter(IncomeReceipt.receipt_date <= datetime.fromisoformat(to_date).date())
    
    # Order by date descending
    query = query.order_by(IncomeReceipt.receipt_date.desc())
    
    receipts = query.all()
    
    return jsonify({
        'receipts': [{
            'id': r.id,
            'receipt_id': r.receipt_id,
            'source': r.source,
            'project_name': r.project.name,
            'description': r.description,
            'amount': str(r.amount),
            'currency': r.currency,
            'amount_usd': str(r.amount_usd),
            'payment_method': r.payment_method,
            'reference_number': r.reference_number,
            'receipt_date': r.receipt_date.isoformat(),
            'recorded_by_name': r.recorded_by.full_name,
            'ledger_reference': r.ledger_reference
        } for r in receipts]
    }), 200


@api_v1.route('/income-receipts', methods=['POST'])
@jwt_required()
def create_income_receipt():
    """Create a new income receipt."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can record income receipts'}), 403
    
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['source', 'project_id', 'description', 'currency', 'amount', 
                      'payment_method', 'receipt_date']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Validate project
    project = Project.query.get(data['project_id'])
    if not project:
        return jsonify({'error': 'Project not found'}), 404
    
    # Get exchange rate
    try:
        exchange_rate = ExchangeRate.get_rate(data['currency'], 'USD')
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    
    amount = Decimal(str(data['amount']))
    amount_usd = amount * Decimal(str(exchange_rate))
    
    # Generate receipt ID
    receipt_id = IDService.generate_income_receipt_id()
    
    receipt = IncomeReceipt(
        receipt_id=receipt_id,
        source=data['source'],
        project_id=data['project_id'],
        description=data['description'],
        currency=data['currency'],
        amount=amount,
        exchange_rate_to_usd=Decimal(str(exchange_rate)),
        amount_usd=amount_usd,
        payment_method=data['payment_method'],
        reference_number=data.get('reference_number'),
        receipt_date=datetime.fromisoformat(data['receipt_date']).date(),
        recorded_by_id=user.id,
        ledger_reference=data.get('ledger_reference')
    )
    
    db.session.add(receipt)
    db.session.commit()
    
    # Log creation
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_CREATE,
        entity_type='IncomeReceipt',
        entity_id=receipt.id,
        note=f"Created income receipt {receipt_id}: {amount} {data['currency']}",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify({
        'message': 'Income receipt created successfully',
        'receipt': income_receipt_schema.dump(receipt)
    }), 201


@api_v1.route('/income-receipts/<int:id>', methods=['GET'])
@jwt_required()
def get_income_receipt(id):
    """Get a specific income receipt."""
    receipt = IncomeReceipt.query.get_or_404(id)
    
    return jsonify({
        'id': receipt.id,
        'receipt_id': receipt.receipt_id,
        'source': receipt.source,
        'project_id': receipt.project_id,
        'project_name': receipt.project.name,
        'description': receipt.description,
        'currency': receipt.currency,
        'amount': str(receipt.amount),
        'amount_usd': str(receipt.amount_usd),
        'payment_method': receipt.payment_method,
        'reference_number': receipt.reference_number,
        'receipt_date': receipt.receipt_date.isoformat(),
        'recorded_by_name': receipt.recorded_by.full_name,
        'ledger_reference': receipt.ledger_reference,
        'created_at': receipt.created_at.isoformat()
    }), 200


@api_v1.route('/income-receipts/<int:id>', methods=['PATCH'])
@jwt_required()
def update_income_receipt(id):
    """Update income receipt (add ledger reference)."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    if user.role != User.ROLE_ACCOUNTANT:
        return jsonify({'error': 'Only accountants can update income receipts'}), 403
    
    receipt = IncomeReceipt.query.get_or_404(id)
    data = request.get_json()
    
    if 'ledger_reference' in data:
        receipt.ledger_reference = data['ledger_reference']
    
    db.session.commit()
    
    # Log update
    AuditLog.log(
        user_id=user.id,
        action=AuditLog.ACTION_UPDATE,
        entity_type='IncomeReceipt',
        entity_id=receipt.id,
        note=f"Updated income receipt",
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    return jsonify(income_receipt_schema.dump(receipt)), 200
