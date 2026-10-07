"""Reports and export endpoints."""
from flask import request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.api.v1 import api_v1
from app.models import ExpenseRequest, User, Project, IncomeReceipt, Reconciliation, AuditLog
from datetime import datetime, timedelta
import csv
import io
from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.enums import TA_CENTER, TA_RIGHT


@api_v1.route('/reports/dashboard-stats', methods=['GET'])
@jwt_required()
def get_dashboard_stats():
    """Get dashboard statistics."""
    current_user_id = get_jwt_identity()
    user = User.query.get(current_user_id)
    
    # Total requests by status
    total_requests = ExpenseRequest.query.count()
    pending_requests = ExpenseRequest.query.filter(
        ExpenseRequest.status.in_(['Submitted', 'Verified', 'Approved'])
    ).count()
    
    # My pending tasks
    my_tasks = 0
    if user.role == User.ROLE_ACCOUNTANT:
        # Pending verification (Submitted) and Pending Ledger Posting (Paid)
        my_tasks = ExpenseRequest.query.filter(
            ExpenseRequest.status.in_([
                ExpenseRequest.STATUS_SUBMITTED,
                ExpenseRequest.STATUS_PAID
            ])
        ).count()
    elif user.role in [User.ROLE_DIRECTOR, User.ROLE_MD, User.ROLE_OPERATION_MANAGER, User.ROLE_MANAGER]:
        # Pending approval
        verified_requests = ExpenseRequest.query.filter(
            ExpenseRequest.status == ExpenseRequest.STATUS_VERIFIED,
            ExpenseRequest.requester_id != user.id
        ).all()
        my_tasks = sum(1 for req in verified_requests if req.can_transition_to(ExpenseRequest.STATUS_APPROVED, user)[0])
    elif user.role == User.ROLE_PAYING_OFFICER:
        # Pending payment
        my_tasks = ExpenseRequest.query.filter(
            ExpenseRequest.status == ExpenseRequest.STATUS_APPROVED,
            ExpenseRequest.requester_id != user.id
        ).count()
    
    period = request.args.get('period', '30d')
    now = datetime.utcnow()
    if period == 'today':
        start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
    elif period == '7d':
        start_date = now - timedelta(days=7)
    elif period == '30d':
        start_date = now - timedelta(days=30)
    elif period == 'this_month':
        start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    elif period == 'this_quarter':
        current_quarter = (now.month - 1) // 3 + 1
        start_month = 3 * current_quarter - 2
        start_date = now.replace(month=start_month, day=1, hour=0, minute=0, second=0, microsecond=0)
    elif period == 'all_time':
        start_date = datetime(2000, 1, 1)
    else:
        start_date = now - timedelta(days=30)
        
    # Financial stats (filtered by date)
    thirty_days_ago = start_date
    
    total_spent = db.session.query(
        db.func.sum(ExpenseRequest.total_amount_usd)
    ).filter(
        ExpenseRequest.status == ExpenseRequest.STATUS_CLOSED,
        ExpenseRequest.closed_at >= thirty_days_ago
    ).scalar() or 0
    
    total_income = db.session.query(
        db.func.sum(IncomeReceipt.amount_usd)
    ).filter(
        IncomeReceipt.created_at >= thirty_days_ago
    ).scalar() or 0
    
    # Pending payments
    pending_payment_amount = db.session.query(
        db.func.sum(ExpenseRequest.total_amount_usd)
    ).filter(
        ExpenseRequest.status == ExpenseRequest.STATUS_APPROVED
    ).scalar() or 0
    
    # Unreconciled differences
    unreconciled_count = Reconciliation.query.filter(
        Reconciliation.status == Reconciliation.STATUS_OPEN,
        Reconciliation.difference != 0
    ).count()

    # Calculate actual KPI metrics requested
    total_expenses = db.session.query(db.func.sum(ExpenseRequest.total_amount_usd)).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED]),
        ExpenseRequest.created_at >= start_date
    ).scalar() or 0
    
    pending_amount = db.session.query(db.func.sum(ExpenseRequest.total_amount_usd)).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_SUBMITTED, ExpenseRequest.STATUS_VERIFIED, ExpenseRequest.STATUS_APPROVED])
    ).scalar() or 0
    
    approved_expenses = db.session.query(db.func.sum(ExpenseRequest.total_amount_usd)).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_APPROVED, ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED]),
        ExpenseRequest.created_at >= start_date
    ).scalar() or 0
    
    from app.models import Project
    total_budget = db.session.query(db.func.sum(Project.budget)).filter(Project.is_active == True).scalar() or 0
    all_time_spent = db.session.query(db.func.sum(ExpenseRequest.total_amount_usd)).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED])
    ).scalar() or 0
    remaining_budget = total_budget - all_time_spent

    # Spending by project
    project_spending = db.session.query(
        Project.name,
        db.func.sum(ExpenseRequest.total_amount_usd).label('total')
    ).join(
        Project, ExpenseRequest.project_id == Project.id
    ).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED]),
        ExpenseRequest.created_at >= start_date
    ).group_by(Project.name).order_by(db.text('total DESC')).limit(5).all()

    # Expenses over time (Daily for the period)
    expenses_over_time = db.session.query(
        db.func.date(ExpenseRequest.created_at).label('date'),
        db.func.sum(ExpenseRequest.total_amount_usd).label('total')
    ).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED]),
        ExpenseRequest.created_at >= start_date
    ).group_by(db.func.date(ExpenseRequest.created_at)).order_by(db.func.date(ExpenseRequest.created_at)).all()

    
    # Spending by category
    from app.models import RequestItem, ExpenseCategory
    category_spending = db.session.query(
        ExpenseCategory.name,
        db.func.sum(RequestItem.total_price).label('total')
    ).join(
        RequestItem, RequestItem.category_id == ExpenseCategory.id
    ).join(
        ExpenseRequest, ExpenseRequest.id == RequestItem.request_id
    ).filter(
        ExpenseRequest.status.in_([ExpenseRequest.STATUS_PAID, ExpenseRequest.STATUS_POSTED, ExpenseRequest.STATUS_CLOSED]),
        ExpenseRequest.created_at >= start_date
    ).group_by(ExpenseCategory.name).order_by(db.desc('total')).limit(5).all()

    return jsonify({
        'total_requests': total_requests,
        'pending_requests': pending_requests,
        'my_tasks': my_tasks,
        
        'total_expenses': float(total_expenses) if total_expenses else 0,
        'pending_amount': float(pending_amount) if pending_amount else 0,
        'approved_expenses': float(approved_expenses) if approved_expenses else 0,
        'remaining_budget': float(remaining_budget) if remaining_budget else 0,
        'total_budget': float(total_budget) if total_budget else 0,
        'all_time_spent': float(all_time_spent) if all_time_spent else 0,
        
        'category_spending': [{'name': str(r[0]), 'total': float(r[1])} for r in category_spending],
        'project_spending': [{'name': str(r[0]), 'total': float(r[1])} for r in project_spending],
        'expenses_over_time': [{'date': r[0].isoformat() if hasattr(r[0], 'isoformat') else str(r[0]), 'total': float(r[1])} for r in expenses_over_time]
    }), 200


@api_v1.route('/reports/export-requests-csv', methods=['GET'])
@jwt_required()
def export_requests_csv():
    """Export expense requests to CSV."""
    # Get filters
    status = request.args.get('status')
    from_date = request.args.get('from_date')
    to_date = request.args.get('to_date')
    project_id = request.args.get('project_id', type=int)
    
    # Build query
    query = ExpenseRequest.query
    
    if status:
        query = query.filter_by(status=status)
    if from_date:
        query = query.filter(ExpenseRequest.request_date >= datetime.fromisoformat(from_date).date())
    if to_date:
        query = query.filter(ExpenseRequest.request_date <= datetime.fromisoformat(to_date).date())
    if project_id:
        query = query.filter_by(project_id=project_id)
    
    requests = query.order_by(ExpenseRequest.request_date.desc()).all()
    
    # Create CSV in memory
    output = io.StringIO()
    writer = csv.writer(output)
    
    # Headers
    writer.writerow([
        'Request ID', 'Date', 'Requester', 'Project', 'Purpose', 
        'Payee', 'Amount', 'Currency', 'Status', 'Approved By', 
        'Approved Date', 'Paid Date'
    ])
    
    # Data
    for req in requests:
        writer.writerow([
            req.request_id,
            req.request_date.isoformat(),
            req.requester.full_name,
            req.project.name,
            req.purpose[:100],  # Truncate long text
            req.payee_name,
            str(req.total_amount),
            req.currency,
            req.status,
            req.approved_by.full_name if req.approved_by else '',
            req.approved_at.isoformat() if req.approved_at else '',
            req.paid_at.isoformat() if req.paid_at else ''
        ])
    
    # Prepare response
    output.seek(0)
    return send_file(
        io.BytesIO(output.getvalue().encode('utf-8')),
        mimetype='text/csv',
        as_attachment=True,
        download_name=f'expense_requests_{datetime.utcnow().strftime("%Y%m%d")}.csv'
    )


@api_v1.route('/reports/export-requests-pdf', methods=['GET'])
@jwt_required()
def export_requests_pdf():
    """Export expense requests to PDF."""
    # Get filters
    status = request.args.get('status')
    from_date = request.args.get('from_date')
    to_date = request.args.get('to_date')
    
    # Build query
    query = ExpenseRequest.query
    
    if status:
        query = query.filter_by(status=status)
    if from_date:
        query = query.filter(ExpenseRequest.request_date >= datetime.fromisoformat(from_date).date())
    if to_date:
        query = query.filter(ExpenseRequest.request_date <= datetime.fromisoformat(to_date).date())
    
    requests = query.order_by(ExpenseRequest.request_date.desc()).limit(100).all()
    
    # Create PDF in memory
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    elements = []
    styles = getSampleStyleSheet()
    
    # Title
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=16,
        textColor=colors.HexColor('#1F4E79'),
        spaceAfter=30,
        alignment=TA_CENTER
    )
    elements.append(Paragraph('Milestone EdTech Solutions Ltd', title_style))
    elements.append(Paragraph('Expense Requests Report', title_style))
    elements.append(Spacer(1, 0.3*inch))
    
    # Filters info
    info_text = f"Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M UTC')}"
    if status:
        info_text += f" | Status: {status}"
    if from_date:
        info_text += f" | From: {from_date}"
    if to_date:
        info_text += f" | To: {to_date}"
    
    elements.append(Paragraph(info_text, styles['Normal']))
    elements.append(Spacer(1, 0.2*inch))
    
    # Table data
    data = [['Request ID', 'Date', 'Requester', 'Amount', 'Status']]
    
    for req in requests:
        data.append([
            req.request_id,
            req.request_date.strftime('%Y-%m-%d'),
            req.requester.full_name[:20],
            f"{req.currency} {req.total_amount:,.2f}",
            req.status
        ])
    
    # Create table
    table = Table(data, colWidths=[1.5*inch, 1*inch, 1.5*inch, 1.2*inch, 1*inch])
    table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#1F4E79')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ('FONTSIZE', (0, 1), (-1, -1), 8),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.lightgrey])
    ]))
    
    elements.append(table)
    elements.append(Spacer(1, 0.3*inch))
    elements.append(Paragraph(f'Total Records: {len(requests)}', styles['Normal']))
    
    # Build PDF
    doc.build(elements)
    buffer.seek(0)
    
    return send_file(
        buffer,
        mimetype='application/pdf',
        as_attachment=True,
        download_name=f'expense_requests_{datetime.utcnow().strftime("%Y%m%d")}.pdf'
    )


@api_v1.route('/reports/audit-trail', methods=['GET'])
@jwt_required()
def get_audit_trail():
    """Get audit trail for a specific entity or date range."""
    entity_type = request.args.get('entity_type')
    entity_id = request.args.get('entity_id', type=int)
    from_date = request.args.get('from_date')
    to_date = request.args.get('to_date')
    limit = request.args.get('limit', 100, type=int)
    
    query = AuditLog.query
    
    if entity_type:
        query = query.filter_by(entity_type=entity_type)
    if entity_id:
        query = query.filter_by(entity_id=entity_id)
    if from_date:
        query = query.filter(AuditLog.created_at >= datetime.fromisoformat(from_date))
    if to_date:
        query = query.filter(AuditLog.created_at <= datetime.fromisoformat(to_date))
    
    logs = query.order_by(AuditLog.created_at.desc()).limit(limit).all()
    
    return jsonify({
        'audit_logs': [{
            'id': log.id,
            'user': log.user.full_name if log.user else 'System',
            'action': log.action,
            'entity_type': log.entity_type,
            'entity_id': log.entity_id,
            'note': log.note,
            'ip_address': log.ip_address,
            'created_at': log.created_at.isoformat()
        } for log in logs]
    }), 200


@api_v1.route('/reports/spending-trends', methods=['GET'])
@jwt_required()
def get_spending_trends():
    """Get spending trends over time (last 12 months)."""
    # Get monthly spending for last 12 months
    twelve_months_ago = datetime.utcnow() - timedelta(days=365)
    
    monthly_spending = db.session.query(
        db.func.date_format(ExpenseRequest.closed_at, '%Y-%m').label('month'),
        db.func.sum(ExpenseRequest.total_amount_usd).label('total')
    ).filter(
        ExpenseRequest.status == ExpenseRequest.STATUS_CLOSED,
        ExpenseRequest.closed_at >= twelve_months_ago
    ).group_by('month').order_by('month').all()
    
    # Monthly income
    monthly_income = db.session.query(
        db.func.date_format(IncomeReceipt.receipt_date, '%Y-%m').label('month'),
        db.func.sum(IncomeReceipt.amount_usd).label('total')
    ).filter(
        IncomeReceipt.receipt_date >= twelve_months_ago.date()
    ).group_by('month').order_by('month').all()
    
    return jsonify({
        'spending': [
            {'month': month, 'amount': float(amt)} 
            for month, amt in monthly_spending
        ],
        'income': [
            {'month': month, 'amount': float(amt)} 
            for month, amt in monthly_income
        ]
    }), 200

@api_v1.route('/reports/exceptions', methods=['GET'])
@jwt_required()
def get_exceptions_report():
    """Get exception report for missing receipts and unretired advances."""
    # Paid requests missing receipts (where payment exists but no receipt attachment)
    # Status is PAID, and not POSTED or CLOSED
    missing_receipts = ExpenseRequest.query.filter(
        ExpenseRequest.status == ExpenseRequest.STATUS_PAID
    ).all()
    
    # Filter those missing receipt attachments
    missing_receipt_data = []
    for req in missing_receipts:
        has_receipt = any(att.attachment_type in ['Receipt', 'Proof of Payment'] for att in req.attachments)
        if not has_receipt:
            missing_receipt_data.append({
                'request_id': req.request_id,
                'requester': req.requester.full_name,
                'payee': req.payee_name,
                'amount': float(req.total_amount_usd),
                'paid_date': req.paid_at.isoformat() if req.paid_at else None
            })
            
    # Unretired advances
    from app.models import Advance
    unretired_advances = Advance.query.filter(
        Advance.is_retired == False
    ).all()
    
    unretired_data = []
    for adv in unretired_advances:
        unretired_data.append({
            'request_id': adv.request.request_id,
            'requester': adv.request.requester.full_name,
            'advance_amount': float(adv.advance_amount),
            'deadline': adv.retirement_deadline.isoformat(),
            'is_overdue': adv.retirement_deadline < datetime.utcnow().date()
        })
        
    return jsonify({
        'missing_receipts': missing_receipt_data,
        'unretired_advances': unretired_data
    }), 200
