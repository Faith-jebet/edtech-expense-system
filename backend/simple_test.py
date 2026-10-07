"""Simple test to isolate the login issue."""
from app import create_app, db
from app.models import User

app = create_app()

with app.app_context():
    try:
        # Try to query a user
        user = User.query.filter_by(email='manager@milestone.com').first()
        if user:
            print(f"[OK] User found: {user.email} ({user.role})")
            print(f"[OK] Password check: {user.check_password('role123')}")
        else:
            print("[ERROR] User not found")
    except Exception as e:
        print(f"[ERROR] {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
