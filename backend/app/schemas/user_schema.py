"""User schemas."""
from marshmallow import Schema, fields, validate


class UserSchema(Schema):
    """User schema for serialization."""
    id = fields.Int(dump_only=True)
    email = fields.Email(required=True)
    first_name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    last_name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    full_name = fields.Str(dump_only=True)
    role = fields.Str(required=True, validate=validate.OneOf([
        'Operation Manager', 'Accountant', 'Director', 
        'Managing Director', 'Paying Officer', 'Admin'
    ]))
    department = fields.Str(allow_none=True)
    phone = fields.Str(allow_none=True)
    is_active = fields.Bool(dump_only=True)
    two_factor_enabled = fields.Bool(dump_only=True)
    signature_path = fields.Str(dump_only=True, allow_none=True)
    last_login = fields.DateTime(dump_only=True, allow_none=True)
    created_at = fields.DateTime(dump_only=True)
    updated_at = fields.DateTime(dump_only=True)


class UserCreateSchema(Schema):
    """Schema for creating a user."""
    email = fields.Email(required=True)
    password = fields.Str(required=True, load_only=True, validate=validate.Length(min=8))
    first_name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    last_name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    role = fields.Str(required=True, validate=validate.OneOf([
        'Operation Manager', 'Accountant', 'Director', 
        'Managing Director', 'Paying Officer', 'Admin'
    ]))
    department = fields.Str(allow_none=True)
    phone = fields.Str(allow_none=True)


class UserUpdateSchema(Schema):
    """Schema for updating a user."""
    first_name = fields.Str(validate=validate.Length(min=1, max=100))
    last_name = fields.Str(validate=validate.Length(min=1, max=100))
    department = fields.Str(allow_none=True)
    phone = fields.Str(allow_none=True)
    is_active = fields.Bool()


class PasswordChangeSchema(Schema):
    """Schema for changing password."""
    current_password = fields.Str(required=True, load_only=True)
    new_password = fields.Str(required=True, load_only=True, validate=validate.Length(min=8))
