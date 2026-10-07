"""API v1 blueprint."""
from flask import Blueprint

api_v1 = Blueprint('api_v1', __name__)

# Import routes to register them
from app.api.v1 import auth, users, projects, categories, expense_requests, reconciliations, income_receipts, reports

__all__ = ['api_v1']
