"""Reconciliation schemas."""
from marshmallow import Schema, fields, validate


class ReconciliationItemSchema(Schema):
    """Reconciliation item schema."""
    id = fields.Int(dump_only=True)
    transaction_date = fields.Date(required=True)
    description = fields.Str(required=True)
    reference = fields.Str(allow_none=True)
    debit = fields.Decimal(as_string=True, places=2)
    credit = fields.Decimal(as_string=True, places=2)
    matched = fields.Bool(dump_only=True)
    matched_request_id = fields.Int(dump_only=True, allow_none=True)
    matched_receipt_id = fields.Int(dump_only=True, allow_none=True)


class ReconciliationSchema(Schema):
    """Reconciliation schema."""
    id = fields.Int(dump_only=True)
    account_type = fields.Str(required=True, validate=validate.OneOf(['Bank', 'Mobile Money', 'Petty Cash']))
    account_name = fields.Str(required=True)
    account_number = fields.Str(allow_none=True)
    period_start = fields.Date(required=True)
    period_end = fields.Date(required=True)
    opening_balance = fields.Decimal(required=True, as_string=True, places=2)
    system_closing_balance = fields.Decimal(required=True, as_string=True, places=2)
    actual_closing_balance = fields.Decimal(required=True, as_string=True, places=2)
    difference = fields.Decimal(dump_only=True, as_string=True, places=2)
    status = fields.Str(dump_only=True)
    explanation = fields.Str(allow_none=True)
    prepared_by_id = fields.Int(dump_only=True)
    prepared_by_name = fields.Str(dump_only=True)
    reviewed_by_id = fields.Int(dump_only=True, allow_none=True)
    reviewed_by_name = fields.Str(dump_only=True, allow_none=True)
    prepared_at = fields.DateTime(dump_only=True)
    reviewed_at = fields.DateTime(dump_only=True, allow_none=True)
    has_unexplained_difference = fields.Bool(dump_only=True)
    items = fields.List(fields.Nested(ReconciliationItemSchema), dump_only=True)


class ReconciliationCreateSchema(Schema):
    """Schema for creating reconciliation."""
    account_type = fields.Str(required=True, validate=validate.OneOf(['Bank', 'Mobile Money', 'Petty Cash']))
    account_name = fields.Str(required=True)
    account_number = fields.Str(allow_none=True)
    period_start = fields.Date(required=True)
    period_end = fields.Date(required=True)
    opening_balance = fields.Decimal(required=True, as_string=True, places=2)
    system_closing_balance = fields.Decimal(required=True, as_string=True, places=2)
    actual_closing_balance = fields.Decimal(required=True, as_string=True, places=2)


class ReconciliationUpdateSchema(Schema):
    """Schema for updating reconciliation."""
    explanation = fields.Str(allow_none=True)
    status = fields.Str(validate=validate.OneOf(['Open', 'Explained', 'Cleared']))


class IncomeReceiptSchema(Schema):
    """Income receipt schema."""
    id = fields.Int(dump_only=True)
    receipt_id = fields.Str(dump_only=True)
    source = fields.Str(required=True)
    project_id = fields.Int(required=True)
    project_name = fields.Str(dump_only=True)
    description = fields.Str(required=True)
    currency = fields.Str(required=True, validate=validate.OneOf(['USD', 'KES', 'Other']))
    amount = fields.Decimal(required=True, as_string=True, places=2)
    exchange_rate_to_usd = fields.Decimal(dump_only=True, as_string=True, places=6)
    amount_usd = fields.Decimal(dump_only=True, as_string=True, places=2)
    payment_method = fields.Str(required=True)
    reference_number = fields.Str(allow_none=True)
    receipt_date = fields.Date(required=True)
    ledger_reference = fields.Str(allow_none=True)
    recorded_by_id = fields.Int(dump_only=True)
    recorded_by_name = fields.Str(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
