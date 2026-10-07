"""Check projects and categories in database."""
from app import create_app, db
from app.models import Project, ExpenseCategory

app = create_app()

with app.app_context():
    projects = Project.query.all()
    categories = ExpenseCategory.query.all()
    
    print(f"Projects: {len(projects)}")
    for p in projects:
        print(f"  - {p.name} ({p.code})")
    
    print(f"\nCategories: {len(categories)}")
    for c in categories:
        print(f"  - {c.name} ({c.code})")
