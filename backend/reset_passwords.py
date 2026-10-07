"""Reset all user passwords to role123."""
from app import create_app, db
from app.models import User

app = create_app()

with app.app_context():
    users = User.query.all()
    
    print(f"Resetting passwords for {len(users)} users...\n")
    
    for user in users:
        user.set_password('role123')
        print(f"✅ Reset password for {user.email} ({user.role})")
    
    db.session.commit()
    print(f"\n✅ All passwords reset to: role123")
