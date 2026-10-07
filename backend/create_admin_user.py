"""
Script to create initial admin user.
Run this after setting up the database in phpMyAdmin.

Usage:
    python create_admin_user.py
"""
from app import create_app, db
from app.models import User
from werkzeug.security import generate_password_hash

def create_admin():
    app = create_app()
    
    with app.app_context():
        # Check if admin already exists
        existing = User.query.filter_by(email='admin@milestone.com').first()
        if existing:
            print("❌ Admin user already exists!")
            print(f"   Email: {existing.email}")
            print(f"   Name: {existing.full_name}")
            return
        
        # Create admin user
        admin = User(
            email='admin@milestone.com',
            password_hash=generate_password_hash('admin123'),
            full_name='System Administrator',
            role=User.ROLE_ADMIN,
            is_active=True
        )
        
        db.session.add(admin)
        db.session.commit()
        
        print("✓ Admin user created successfully!")
        print()
        print("Login credentials:")
        print("  Email: admin@milestone.com")
        print("  Password: admin123")
        print()
        print("⚠️  IMPORTANT: Change this password after first login!")


def reset_admin_password():
    """Reset the development admin password to the documented value."""
    app = create_app()

    with app.app_context():
        admin = User.query.filter_by(email='admin@milestone.com').first()
        if not admin:
            print("❌ Admin user does not exist. Run: python create_admin_user.py")
            return

        admin.set_password('admin123')
        admin.is_active = True
        db.session.commit()
        print("✓ Admin password reset successfully!")
        print("  Email: admin@milestone.com")
        print("  Password: admin123")

def create_demo_users():
    """Create demo users for each role."""
    app = create_app()
    
    with app.app_context():
        demo_users = [
            {
                'email': 'operations@milestone.com',
                'password': 'password123',
                'full_name': 'Sarah Operations',
                'role': User.ROLE_OPERATION_MANAGER
            },
            {
                'email': 'payments@milestone.com',
                'password': 'password123',
                'full_name': 'David Payments',
                'role': User.ROLE_PAYING_OFFICER
            },
            {
                'email': 'accountant@milestone.com',
                'password': 'accountant123',
                'full_name': 'Mary Accountant',
                'role': User.ROLE_ACCOUNTANT
            },
            {
                'email': 'director@milestone.com',
                'password': 'director123',
                'full_name': 'David Director',
                'role': User.ROLE_DIRECTOR
            },
            {
                'email': 'md@milestone.com',
                'password': 'password123',
                'full_name': 'Sarah Managing Director',
                'role': User.ROLE_MANAGING_DIRECTOR
            },
        ]
        
        created = 0
        for user_data in demo_users:
            # Check if user exists
            existing = User.query.filter_by(email=user_data['email']).first()
            if existing:
                print(f"⊘ {user_data['email']} already exists, skipping...")
                continue
            
            # Create user
            user = User(
                email=user_data['email'],
                password_hash=generate_password_hash(user_data['password']),
                full_name=user_data['full_name'],
                role=user_data['role'],
                is_active=True
            )
            
            db.session.add(user)
            created += 1
            print(f"✓ Created: {user_data['full_name']} ({user_data['role']})")
        
        if created > 0:
            db.session.commit()
            print()
            print(f"✓ {created} demo user(s) created successfully!")
            print()
            print("Demo Credentials:")
            for user_data in demo_users:
                print(f"  {user_data['role']:20s} - {user_data['email']:30s} / {user_data['password']}")
        else:
            print()
            print("ℹ All demo users already exist.")

if __name__ == '__main__':
    import sys
    
    print("=" * 60)
    print("Milestone EdTech - User Creation Script")
    print("=" * 60)
    print()
    
    if len(sys.argv) > 1 and sys.argv[1] == '--reset-admin':
        print("Resetting development admin password...")
        print()
        reset_admin_password()
    elif len(sys.argv) > 1 and sys.argv[1] == '--demo':
        print("Creating admin and demo users...")
        print()
        create_admin()
        print()
        create_demo_users()
    else:
        print("Creating admin user only...")
        print("(Use --demo flag to create demo users for all roles)")
        print()
        create_admin()
    
    print()
    print("=" * 60)
