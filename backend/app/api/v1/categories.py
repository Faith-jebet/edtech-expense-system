"""Expense category endpoints."""
from flask import request, jsonify
from flask_jwt_extended import jwt_required
from app.api.v1 import api_v1
from app.models import ExpenseCategory


@api_v1.route('/expense-categories', methods=['GET'])
@jwt_required()
def list_expense_categories():
    """List all active expense categories."""
    categories = ExpenseCategory.query.filter_by(is_active=True).all()
    
    return jsonify({
        'categories': [{
            'id': c.id,
            'code': c.code,
            'name': c.name,
            'description': c.description,
            'is_active': c.is_active
        } for c in categories]
    }), 200


@api_v1.route('/expense-categories/<int:id>', methods=['GET'])
@jwt_required()
def get_expense_category(id):
    """Get a specific expense category."""
    category = ExpenseCategory.query.get_or_404(id)
    
    return jsonify({
        'id': category.id,
        'code': category.code,
        'name': category.name,
        'description': category.description,
        'is_active': category.is_active
    }), 200
