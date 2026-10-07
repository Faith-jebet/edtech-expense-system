"""Application entry point."""
import os
from app import create_app, db
from app.models import *

# Create app instance
app = create_app(os.getenv('FLASK_ENV', 'development'))


@app.shell_context_processor
def make_shell_context():
    """Make database models available in flask shell."""
    return {
        'db': db,
        'User': User,
        'Project': Project,
        'ExpenseCategory': ExpenseCategory,
        'ExpenseRequest': ExpenseRequest,
        'RequestItem': RequestItem,
        'Attachment': Attachment,
        'Approval': Approval,
        'Payment': Payment,
        'Advance': Advance,
        'IncomeReceipt': IncomeReceipt,
        'Reconciliation': Reconciliation,
        'ReconciliationItem': ReconciliationItem,
        'ExchangeRate': ExchangeRate,
        'Setting': Setting,
        'IDCounter': IDCounter,
        'AuditLog': AuditLog
    }


@app.cli.command()
def seed():
    """Seed the database with demo data."""
    from datetime import date, datetime, timedelta
    from decimal import Decimal
    from app.services.id_service import IDService
    
    print("Seeding database...")
    
    # Create users
    print("Creating users...")
    
    # Admin
    admin = User(
        email='admin@milestonetech.com',
        first_name='Admin',
        last_name='User',
        role=User.ROLE_ADMIN,
        department='IT',
        is_active=True
    )
    admin.set_password('admin123')
    db.session.add(admin)
    
    # Operation Manager
    op_manager = User(
        email='operations@milestonetech.com',
        first_name='Sarah',
        last_name='Operations',
        role=User.ROLE_OPERATION_MANAGER,
        department='Operations',
        phone='+254712345678',
        is_active=True
    )
    op_manager.set_password('password123')
    db.session.add(op_manager)
    
    # Accountant
    accountant = User(
        email='accountant@milestonetech.com',
        first_name='Jane',
        last_name='Mwangi',
        role=User.ROLE_ACCOUNTANT,
        department='Finance',
        phone='+254723456789',
        is_active=True
    )
    accountant.set_password('password123')
    db.session.add(accountant)
    
    # Director
    director = User(
        email='director@milestonetech.com',
        first_name='John',
        last_name='Kamau',
        role=User.ROLE_DIRECTOR,
        department='Management',
        phone='+254734567890',
        is_active=True
    )
    director.set_password('password123')
    db.session.add(director)
    
    # Managing Director
    md = User(
        email='md@milestonetech.com',
        first_name='Mary',
        last_name='Wanjiku',
        role=User.ROLE_MANAGING_DIRECTOR,
        department='Executive',
        phone='+254745678901',
        is_active=True
    )
    md.set_password('password123')
    db.session.add(md)
    
    # Paying Officer
    paying_officer = User(
        email='payments@milestonetech.com',
        first_name='David',
        last_name='Omondi',
        role=User.ROLE_PAYING_OFFICER,
        department='Finance',
        phone='+254756789012',
        is_active=True
    )
    paying_officer.set_password('password123')
    db.session.add(paying_officer)
    
    db.session.commit()
    print(f"Created {User.query.count()} users")
    
    # Create projects
    print("Creating projects...")
    
    projects_data = [
        ('PROJ-001', 'EdTech Platform Development', 'Development of the main platform', 50000.00),
        ('PROJ-002', 'Teacher Training Program', 'Training workshops for teachers', 25000.00),
        ('PROJ-003', 'Marketing Campaign Q4', 'Q4 marketing and outreach', 15000.00),
        ('PROJ-004', 'Infrastructure Upgrade', 'Server and network upgrades', 30000.00)
    ]
    
    projects = []
    for code, name, desc, budget in projects_data:
        proj = Project(
            code=code,
            name=name,
            description=desc,
            budget_usd=Decimal(str(budget)),
            spent_usd=Decimal('0'),
            is_active=True,
            start_date=date(2026, 1, 1),
            end_date=date(2026, 12, 31)
        )
        db.session.add(proj)
        projects.append(proj)
    
    db.session.commit()
    print(f"Created {len(projects)} projects")
    
    # Create expense categories
    print("Creating expense categories...")
    
    categories_data = [
        ('TRAVEL', 'Travel and Accommodation', 'Travel, transport, and lodging'),
        ('SUPPLIES', 'Office Supplies', 'Stationery, equipment, and office materials'),
        ('UTILITIES', 'Utilities', 'Internet, electricity, water'),
        ('MARKETING', 'Marketing and Advertising', 'Promotional activities and campaigns'),
        ('TRAINING', 'Training and Development', 'Staff training and professional development'),
        ('CONSULTING', 'Consulting Services', 'External consultants and advisors'),
        ('SOFTWARE', 'Software and Licenses', 'Software subscriptions and licenses'),
        ('MAINTENANCE', 'Maintenance and Repairs', 'Equipment and facility maintenance')
    ]
    
    categories = []
    for code, name, desc in categories_data:
        cat = ExpenseCategory(
            code=code,
            name=name,
            description=desc,
            is_active=True
        )
        db.session.add(cat)
        categories.append(cat)
    
    db.session.commit()
    print(f"Created {len(categories)} expense categories")
    
    # Create exchange rates
    print("Creating exchange rates...")
    
    rates = [
        ('USD', 'USD', Decimal('1.0')),
        ('KES', 'USD', Decimal('0.0078')),  # Approximately 128 KES = 1 USD
        ('EUR', 'USD', Decimal('1.08')),
        ('GBP', 'USD', Decimal('1.27'))
    ]
    
    for from_curr, to_curr, rate in rates:
        ex_rate = ExchangeRate(
            from_currency=from_curr,
            to_currency=to_curr,
            rate=rate,
            effective_date=date(2026, 1, 1),
            is_active=True,
            created_by_id=admin.id
        )
        db.session.add(ex_rate)
    
    db.session.commit()
    print(f"Created {ExchangeRate.query.count()} exchange rates")
    
    # Create sample expense requests in various statuses
    print("Creating sample expense requests...")
    
    # Request 1: Draft (by op_manager)
    req1_id = IDService.generate_expense_request_id(2026)
    req1 = ExpenseRequest(
        request_id=req1_id,
        requester_id=op_manager.id,
        department='Operations',
        project_id=projects[0].id,
        category_id=categories[0].id,
        priority=ExpenseRequest.PRIORITY_NORMAL,
        payee_name='Safari Travel Agency',
        payee_details='Bank: KCB, Account: 1234567890',
        currency='KES',
        exchange_rate_to_usd=Decimal('0.0078'),
        total_amount=Decimal('8000.00'),
        total_amount_usd=Decimal('62.40'),
        business_justification='Travel to Nairobi for client meetings',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        budget_status=ExpenseRequest.BUDGET_WITHIN,
        status=ExpenseRequest.STATUS_DRAFT
    )
    db.session.add(req1)
    
    item1 = RequestItem(
        request_id=req1.id,
        description='Round trip flight tickets',
        quantity=Decimal('2'),
        unit_cost=Decimal('4000.00'),
        amount=Decimal('8000.00')
    )
    db.session.add(item1)
    
    # Request 2: Submitted (by op_manager)
    req2_id = IDService.generate_expense_request_id(2026)
    req2 = ExpenseRequest(
        request_id=req2_id,
        requester_id=op_manager.id,
        department='Operations',
        project_id=projects[1].id,
        category_id=categories[1].id,
        priority=ExpenseRequest.PRIORITY_URGENT,
        payee_name='Office Supplies Ltd',
        currency='USD',
        exchange_rate_to_usd=Decimal('1.0'),
        total_amount=Decimal('150.00'),
        total_amount_usd=Decimal('150.00'),
        business_justification='Urgent supplies for training workshop',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        budget_status=ExpenseRequest.BUDGET_WITHIN,
        status=ExpenseRequest.STATUS_SUBMITTED,
        submitted_at=datetime.utcnow() - timedelta(hours=2)
    )
    db.session.add(req2)
    
    item2a = RequestItem(
        request_id=req2.id,
        description='Training materials and folders',
        quantity=Decimal('50'),
        unit_cost=Decimal('2.00'),
        amount=Decimal('100.00')
    )
    item2b = RequestItem(
        request_id=req2.id,
        description='Whiteboard markers',
        quantity=Decimal('25'),
        unit_cost=Decimal('2.00'),
        amount=Decimal('50.00')
    )
    db.session.add_all([item2a, item2b])
    
    # Request 3: Verified (awaiting approval)
    req3_id = IDService.generate_expense_request_id(2026)
    req3 = ExpenseRequest(
        request_id=req3_id,
        requester_id=op_manager.id,
        department='Operations',
        project_id=projects[2].id,
        category_id=categories[3].id,
        priority=ExpenseRequest.PRIORITY_NORMAL,
        payee_name='Digital Marketing Co',
        currency='USD',
        exchange_rate_to_usd=Decimal('1.0'),
        total_amount=Decimal('800.00'),
        total_amount_usd=Decimal('800.00'),
        business_justification='Social media advertising campaign',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        budget_status=ExpenseRequest.BUDGET_WITHIN,
        status=ExpenseRequest.STATUS_VERIFIED,
        submitted_at=datetime.utcnow() - timedelta(days=2),
        verified_at=datetime.utcnow() - timedelta(days=1),
        verified_by_id=accountant.id
    )
    db.session.add(req3)
    
    item3 = RequestItem(
        request_id=req3.id,
        description='Facebook and Instagram ads - Q4',
        quantity=Decimal('1'),
        unit_cost=Decimal('800.00'),
        amount=Decimal('800.00')
    )
    db.session.add(item3)
    
    # Request 4: Approved (awaiting payment)
    req4_id = IDService.generate_expense_request_id(2026)
    req4 = ExpenseRequest(
        request_id=req4_id,
        requester_id=op_manager.id,
        department='Operations',
        project_id=projects[0].id,
        category_id=categories[6].id,
        priority=ExpenseRequest.PRIORITY_NORMAL,
        payee_name='CloudHost Services',
        currency='USD',
        exchange_rate_to_usd=Decimal('1.0'),
        total_amount=Decimal('250.00'),
        total_amount_usd=Decimal('250.00'),
        business_justification='Monthly cloud hosting - November 2026',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        budget_status=ExpenseRequest.BUDGET_WITHIN,
        status=ExpenseRequest.STATUS_APPROVED,
        submitted_at=datetime.utcnow() - timedelta(days=5),
        verified_at=datetime.utcnow() - timedelta(days=4),
        verified_by_id=accountant.id,
        approved_at=datetime.utcnow() - timedelta(days=3),
        approved_by_id=director.id
    )
    db.session.add(req4)
    
    item4 = RequestItem(
        request_id=req4.id,
        description='Cloud hosting and storage',
        quantity=Decimal('1'),
        unit_cost=Decimal('250.00'),
        amount=Decimal('250.00')
    )
    db.session.add(item4)
    
    # Request 5: Closed (complete)
    req5_id = IDService.generate_expense_request_id(2026)
    req5 = ExpenseRequest(
        request_id=req5_id,
        requester_id=op_manager.id,
        department='Operations',
        project_id=projects[1].id,
        category_id=categories[4].id,
        priority=ExpenseRequest.PRIORITY_NORMAL,
        payee_name='Training Solutions Ltd',
        currency='KES',
        exchange_rate_to_usd=Decimal('0.0078'),
        total_amount=Decimal('12800.00'),
        total_amount_usd=Decimal('99.84'),
        business_justification='Facilitator fees for teacher training',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        budget_status=ExpenseRequest.BUDGET_WITHIN,
        status=ExpenseRequest.STATUS_CLOSED,
        submitted_at=datetime.utcnow() - timedelta(days=15),
        verified_at=datetime.utcnow() - timedelta(days=14),
        verified_by_id=accountant.id,
        approved_at=datetime.utcnow() - timedelta(days=13),
        approved_by_id=director.id,
        paid_at=datetime.utcnow() - timedelta(days=10),
        posted_at=datetime.utcnow() - timedelta(days=8),
        closed_at=datetime.utcnow() - timedelta(days=7)
    )
    db.session.add(req5)
    
    item5 = RequestItem(
        request_id=req5.id,
        description='2-day training facilitation',
        quantity=Decimal('2'),
        unit_cost=Decimal('6400.00'),
        amount=Decimal('12800.00')
    )
    db.session.add(item5)
    
    # Add payment record for closed request
    payment5 = Payment(
        request_id=req5.id,
        paid_by_id=paying_officer.id,
        payment_reference='TXN-20261001-001',
        payment_method=ExpenseRequest.PAYMENT_BANK_TRANSFER,
        actual_amount_paid=Decimal('12800.00'),
        payment_date=date.today() - timedelta(days=10),
        receipt_attached=True,
        ledger_reference='LED-2026-10-123',
        posted_by_id=accountant.id,
        posted_at=datetime.utcnow() - timedelta(days=8)
    )
    db.session.add(payment5)
    
    # Update project spent amount
    projects[1].spent_usd += req5.total_amount_usd
    
    db.session.commit()
    print(f"Created {ExpenseRequest.query.count()} sample expense requests")
    
    # Create settings
    print("Creating settings...")
    
    Setting.set('approval_sla_days', 2, 'integer', 'Days for approval turnaround', 'sla', admin.id)
    Setting.set('payment_sla_days', 3, 'integer', 'Days for payment after approval', 'sla', admin.id)
    Setting.set('receipt_sla_days', 5, 'integer', 'Days for receipt upload after payment', 'sla', admin.id)
    Setting.set('advance_retirement_days', 14, 'integer', 'Days for advance retirement', 'advance', admin.id)
    Setting.set('payment_tolerance_percent', 2.0, 'decimal', 'Payment amount tolerance %', 'payment', admin.id)
    
    db.session.commit()
    print(f"Created {Setting.query.count()} settings")
    
    print("\n=== Seed Complete ===")
    print("\nDemo Users:")
    print("  Admin:             admin@milestonetech.com / admin123")
    print("  Operation Manager: operations@milestonetech.com / password123")
    print("  Accountant:        accountant@milestonetech.com / password123")
    print("  Director:          director@milestonetech.com / password123")
    print("  Managing Director: md@milestonetech.com / password123")
    print("  Paying Officer:    payments@milestonetech.com / password123")
    print("\nProjects:", len(projects))
    print("Categories:", len(categories))
    print("Expense Requests:", ExpenseRequest.query.count())
    print("  - Draft:", ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_DRAFT).count())
    print("  - Submitted:", ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_SUBMITTED).count())
    print("  - Verified:", ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_VERIFIED).count())
    print("  - Approved:", ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_APPROVED).count())
    print("  - Closed:", ExpenseRequest.query.filter_by(status=ExpenseRequest.STATUS_CLOSED).count())


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
