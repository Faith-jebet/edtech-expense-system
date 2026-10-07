"""Authentication endpoints."""
from flask import request, jsonify
from flask_jwt_extended import (
    create_access_token, create_refresh_token, jwt_required,
    get_jwt_identity, set_refresh_cookies, unset_jwt_cookies
)
from app import db, jwt
from app.api.v1 import api_v1
from app.models import User, AuditLog
from datetime import datetime


@jwt.user_identity_loader
def user_identity_lookup(user_id):
    """Convert user object to identity."""
    return user_id


@jwt.user_lookup_loader
def user_lookup_callback(_jwt_header, jwt_data):
    """Load user from JWT token."""
    identity = int(jwt_data["sub"])
    return User.query.get(identity)


def configure_jwt_handlers(jwt_manager):
    """Configure JWT error handlers."""
    
    @jwt_manager.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return jsonify({
            'error': 'Token has expired',
            'message': 'Please log in again'
        }), 401
    
    @jwt_manager.invalid_token_loader
    def invalid_token_callback(error):
        return jsonify({
            'error': 'Invalid token',
            'message': 'Please log in again'
        }), 401
    
    @jwt_manager.unauthorized_loader
    def missing_token_callback(error):
        return jsonify({
            'error': 'Authorization required',
            'message': 'Please log in to access this resource'
        }), 401



@api_v1.route('/auth/signup', methods=['POST'])
def signup():
    """
    User signup.
    Request: {"full_name": "...", "email": "...", "password": "...", "role": "..."}
    """
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    role = data.get('role')
    
    if not email or not password or not full_name or not role:
        return jsonify({'error': 'All fields are required'}), 400
        
    existing_user = User.query.filter_by(email=email).first()
    if existing_user:
        return jsonify({'error': 'Email is already registered'}), 400
        
    try:
        new_user = User(
            email=email,
            full_name=full_name,
            role=role,
            is_active=True
        )
        new_user.set_password(password)
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

@api_v1.route('/auth/login', methods=['POST'])
def login():
    """
    User login.
    Request: {"email": "user@example.com", "password": "password"}
    Response: {"access_token": "...", "user": {...}}
    Refresh token is set in HttpOnly cookie.
    """
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')
    
    if not email or not password:
        return jsonify({'error': 'Email and password required'}), 400
    
    user = User.query.filter_by(email=email).first()
    
    if not user or not user.check_password(password):
        return jsonify({'error': 'Invalid email or password'}), 401
    
    if not user.is_active:
        return jsonify({'error': 'Account is inactive'}), 403

    if user.role == 'Staff':
        return jsonify({
            'error': 'Staff accounts are not part of the finance workflow. Contact an administrator.'
        }), 403
    
    # Log login
    audit_log = AuditLog(
        user_id=user.id,
        action='LOGIN',
        entity_type='User',
        entity_id=user.id,
        note='User logged in',
        ip_address=request.remote_addr
    )
    db.session.add(audit_log)
    db.session.commit()
    
    # Create tokens
    access_token = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))
    
    response = jsonify({
        'access_token': access_token,
        'user': {
            'id': user.id,
            'email': user.email,
            'full_name': user.full_name,
            'role': user.role
        }
    })
    
    # Set refresh token in HttpOnly cookie
    set_refresh_cookies(response, refresh_token)
    
    return response, 200


@api_v1.route('/auth/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """
    Refresh access token using refresh token from cookie.
    Response: {"access_token": "..."}
    """
    current_user_id = get_jwt_identity()
    access_token = create_access_token(identity=str(current_user_id))
    
    return jsonify({'access_token': access_token}), 200


@api_v1.route('/auth/logout', methods=['POST'])
@jwt_required()
def logout():
    """
    Logout user.
    Clears JWT cookies and logs the action.
    """
    current_user_id = get_jwt_identity()
    
    # Log logout
    AuditLog.log(
        user_id=current_user_id,
        action=AuditLog.ACTION_LOGOUT,
        entity_type='User',
        entity_id=current_user_id,
        note='User logged out',
        ip_address=request.remote_addr
    )
    db.session.commit()
    
    response = jsonify({'message': 'Logged out successfully'})
    unset_jwt_cookies(response)
    
    return response, 200


@api_v1.route('/auth/me', methods=['GET'])
@jwt_required()
def get_current_user():
    """
    Get current authenticated user.
    Response: {"user": {...}}
    """
    current_user = get_jwt_identity()
    user = User.query.get(current_user)
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify({
        'user': {
            'id': user.id,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'full_name': user.full_name,
            'role': user.role,
            'department': user.department,
            'phone': user.phone,
            'two_factor_enabled': user.two_factor_enabled
        }
    }), 200
