"""Project management endpoints."""
from flask import request, jsonify
from flask_jwt_extended import jwt_required
from app.api.v1 import api_v1
from app.models import Project


@api_v1.route('/projects', methods=['GET'])
@jwt_required()
def list_projects():
    """List all active projects."""
    projects = Project.query.filter_by(is_active=True).all()
    
    return jsonify({
        'projects': [{
            'id': p.id,
            'code': p.code,
            'name': p.name,
            'description': p.description,
            'budget': str(p.budget) if p.budget else None,
            'currency': p.currency,
            'is_active': p.is_active,
            'start_date': p.start_date.isoformat() if p.start_date else None,
            'end_date': p.end_date.isoformat() if p.end_date else None
        } for p in projects]
    }), 200


@api_v1.route('/projects/<int:id>', methods=['GET'])
@jwt_required()
def get_project(id):
    """Get a specific project."""
    project = Project.query.get_or_404(id)
    
    return jsonify({
        'id': project.id,
        'code': project.code,
        'name': project.name,
        'description': project.description,
        'budget': str(project.budget) if project.budget else None,
        'currency': project.currency,
        'is_active': project.is_active,
        'start_date': project.start_date.isoformat() if project.start_date else None,
        'end_date': project.end_date.isoformat() if project.end_date else None
    }), 200
