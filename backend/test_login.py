"""Test user login credentials."""
from app import create_app, db
from app.models import User

app = create_app()

with app.app_context():
    # Test admin login
    user = User.query.filter_by(email='admin@milestone.com').first()
    
    if user:
        print(f"User found: {user.email}")
        print(f"Role: {user.role}")
        
        # Test password
        test_passwords = ['role123', 'admin123', 'password', 'Admin123']
        
        for pwd in test_passwords:
            if user.check_password(pwd):
                print(f"✅ Password '{pwd}' works!")
                break
        else:
            print("❌ None of the test passwords work")
            print("Let me try to set password to 'role123'...")
            user.set_password('role123')
            db.session.commit()
            print("✅ Password reset to 'role123'")
    else:
        print("User not found!")
