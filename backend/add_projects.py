"""Add sample projects to database."""
from app import create_app, db
from app.models import Project
from datetime import date

app = create_app()

with app.app_context():
    # Check if projects exist
    existing = Project.query.count()
    if existing > 0:
        print(f"Projects already exist: {existing}")
    else:
        # Add default projects
        projects = [
            Project(
                code='GEN-2026',
                name='General Operations 2026',
                description='General operational expenses for 2026',
                budget=50000.00,
                currency='USD',
                start_date=date(2026, 1, 1),
                end_date=date(2026, 12, 31),
                is_active=True
            ),
            Project(
                code='EDU-001',
                name='EdTech Platform Development',
                description='Development of online learning platform',
                budget=100000.00,
                currency='USD',
                start_date=date(2026, 1, 1),
                end_date=date(2026, 6, 30),
                is_active=True
            ),
            Project(
                code='MKT-001',
                name='Marketing Campaign Q1 2026',
                description='Digital marketing and brand awareness campaign',
                budget=25000.00,
                currency='USD',
                start_date=date(2026, 1, 1),
                end_date=date(2026, 3, 31),
                is_active=True
            )
        ]
        
        for project in projects:
            db.session.add(project)
        
        db.session.commit()
        print(f"Added {len(projects)} projects successfully!")
        
        # Display
        for p in projects:
            print(f"  - {p.name} ({p.code}) - Budget: {p.currency} {p.budget}")
