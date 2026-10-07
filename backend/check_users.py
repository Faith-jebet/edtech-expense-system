"""Check users in database."""
from app import create_app, db
from app.models import User

app = create_app()

with app.app_context():
    users = User.query.all()
    
    print(f"Total users: {len(users)}\n")
    
    for u in users:
        print(f"Email: {u.email}")
        print(f"  Role: {u.role}")
        print(f"  Active: {u.is_active}")
        print(f"  Has password hash: {bool(u.password_hash)}")
        print()
