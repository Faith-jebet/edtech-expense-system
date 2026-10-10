"""Expense request schemas."""
from marshmallow import Schema, fields, validate, validates, ValidationError
from decimal import Decimal


class RequestItemSchema(Schema):
    """Request item schema."""
    id = fields.Int(dump_only=True)
    description = fields.Str(required=True)
    quantity = fields.Decimal(required=True, as_string=True, places=2)
    unit_cost = fields.Decimal(required=True, as_string=True, places=2)
    amount = fields.Decimal(dump_only=True, as_string=True, places=2)
    created_at = fields.DateTime(dump_only=True)
    
    @validates('quantity')
    def validate_quantity(self, value):
        if value <= 0:
            raise ValidationError('Quantity must be greater than zero')
    
    @validates('unit_cost')
    def validate_unit_cost(self, value):
        if value < 0:
            raise ValidationError('Unit cost cannot be negative')


class AttachmentSchema(Schema):
    """Attachment schema."""
    id = fields.Int(dump_only=True)
    attachment_type = fields.Str(required=True, validate=validate.OneOf([
        'Quotation', 'Invoice', 'Purchase Order', 'Contract', 
        'Receipt', 'Proof of Payment', 'Cash Voucher', 'Other'
    ]))
    filename = fields.Str(dump_only=True)
    filesize = fields.Int(dump_only=True)
    mime_type = fields.Str(dump_only=True)
    description = fields.Str(allow_none=True)
    uploaded_by_id = fields.Int(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    # URL to download file
    download_url = fields.Str(dump_only=True)


class ApprovalSchema(Schema):
    """Approval schema."""
    id = fields.Int(dump_only=True)
    approver_id = fields.Int(dump_only=True)
    approver_name = fields.Str(dump_only=True)
    decision = fields.Str(dump_only=True)
    comments = fields.Str(allow_none=True)
    signature_text = fields.Str(allow_none=True)
    ip_address = fields.Str(dump_only=True)
    created_at = fields.DateTime(dump_only=True)


class PaymentSchema(Schema):
    """Payment schema."""
    id = fields.Int(dump_only=True)
    paid_by_id = fields.Int(dump_only=True)
    paid_by_name = fields.Str(dump_only=True)
    payment_reference = fields.Str(dump_only=True)
    payment_method = fields.Str(dump_only=True)
    actual_amount_paid = fields.Decimal(dump_only=True, as_string=True, places=2)
    payment_date = fields.Date(dump_only=True)
    payment_notes = fields.Str(dump_only=True, allow_none=True)
    receipt_attached = fields.Bool(dump_only=True)
    ledger_reference = fields.Str(dump_only=True, allow_none=True)
    posted_by_id = fields.Int(dump_only=True, allow_none=True)
    posted_by_name = fields.Str(dump_only=True, allow_none=True)
    posted_at = fields.DateTime(dump_only=True, allow_none=True)
    posting_notes = fields.Str(dump_only=True, allow_none=True)


class ExpenseRequestSchema(Schema):
    """Expense request schema."""
    id = fields.Int(dump_only=True)
    request_id = fields.Str(dump_only=True)
    
    # Request header
    requester_id = fields.Int(dump_only=True)
    requester_name = fields.Str(dump_only=True)
    department = fields.Str(allow_none=True)
    project_id = fields.Int(required=True)
    project_name = fields.Str(dump_only=True)
    category_id = fields.Int(required=True)
    category_name = fields.Str(dump_only=True)
    priority = fields.Str(required=True, validate=validate.OneOf(['Normal', 'Urgent']))
    
    # Payee
    payee_name = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    payee_details = fields.Str(allow_none=True)
    
    # Currency and amounts
    currency = fields.Str(required=True, validate=validate.OneOf(['USD', 'KES', 'Other']))
    currency_other = fields.Str(allow_none=True)
    exchange_rate_to_usd = fields.Decimal(dump_only=True, as_string=True, places=6)
    total_amount = fields.Decimal(dump_only=True, as_string=True, places=2)
    total_amount_usd = fields.Decimal(dump_only=True, as_string=True, places=2)
    
    # Request details
    business_justification = fields.Str(required=True)
    payment_method = fields.Str(required=True, validate=validate.OneOf([
        'Bank Transfer', 'Mobile Money', 'Cash', 'Other'
    ]))
    budget_status = fields.Str(required=True, validate=validate.OneOf([
        'Within Budget', 'Outside Budget-Exception'
    ]))
    expected_payment_date = fields.Date(allow_none=True)
    
    # Workflow
    status = fields.Str(dump_only=True)
    
    # Advance
    is_advance = fields.Bool(missing=False)
    advance_retirement_deadline = fields.Date(allow_none=True)
    advance_retired = fields.Bool(dump_only=True)
    
    # Split purchase
    split_purchase_flag = fields.Bool(dump_only=True)
    split_purchase_note = fields.Str(dump_only=True, allow_none=True)
    
    # Timestamps
    created_at = fields.DateTime(dump_only=True)
    submitted_at = fields.DateTime(dump_only=True, allow_none=True)
    verified_at = fields.DateTime(dump_only=True, allow_none=True)
    approved_at = fields.DateTime(dump_only=True, allow_none=True)
    rejected_at = fields.DateTime(dump_only=True, allow_none=True)
    paid_at = fields.DateTime(dump_only=True, allow_none=True)
    posted_at = fields.DateTime(dump_only=True, allow_none=True)
    closed_at = fields.DateTime(dump_only=True, allow_none=True)
    
    # SLA
    approval_due_date = fields.DateTime(dump_only=True, allow_none=True)
    payment_due_date = fields.DateTime(dump_only=True, allow_none=True)
    receipt_due_date = fields.DateTime(dump_only=True, allow_none=True)
    is_overdue = fields.Bool(dump_only=True)
    
    # Related users
    verified_by_id = fields.Int(dump_only=True, allow_none=True)
    verified_by_name = fields.Str(dump_only=True, allow_none=True)
    approved_by_id = fields.Int(dump_only=True, allow_none=True)
    approved_by_name = fields.Str(dump_only=True, allow_none=True)
    rejected_by_id = fields.Int(dump_only=True, allow_none=True)
    rejected_by_name = fields.Str(dump_only=True, allow_none=True)
    rejection_reason = fields.Str(dump_only=True, allow_none=True)
    
    # Nested relationships
    items = fields.List(fields.Nested(RequestItemSchema), required=True)
    attachments = fields.List(fields.Nested(AttachmentSchema), dump_only=True)
    approvals = fields.List(fields.Nested(ApprovalSchema), dump_only=True)
    payments = fields.List(fields.Nested(PaymentSchema), dump_only=True, allow_none=True)


class ExpenseRequestCreateSchema(Schema):
    """Schema for creating an expense request."""
    department = fields.Str(allow_none=True)
    project_id = fields.Int(required=False, allow_none=True)
    new_project_name = fields.Str(required=False, allow_none=True)
    category_id = fields.Int(required=True)
    priority = fields.Str(required=True, validate=validate.OneOf(['Normal', 'Urgent']))
    
    payee_name = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    payee_details = fields.Str(allow_none=True)
    
    currency = fields.Str(required=True, validate=validate.OneOf(['USD', 'KES', 'Other']))
    currency_other = fields.Str(allow_none=True)
    
    business_justification = fields.Str(required=True)
    payment_method = fields.Str(required=True, validate=validate.OneOf([
        'Bank Transfer', 'Mobile Money', 'Cash', 'Other'
    ]))
    budget_status = fields.Str(required=True, validate=validate.OneOf([
        'Within Budget', 'Outside Budget-Exception'
    ]))
    expected_payment_date = fields.Date(allow_none=True)
    
    is_advance = fields.Bool(missing=False)
    advance_retirement_deadline = fields.Date(allow_none=True)
    
    items = fields.List(fields.Nested(RequestItemSchema), required=True, validate=validate.Length(min=1))


class ApprovalActionSchema(Schema):
    """Schema for approval/rejection action."""
    decision = fields.Str(required=True, validate=validate.OneOf(['Approved', 'Rejected', 'Verified']))
    comments = fields.Str(allow_none=True)
    signature_text = fields.Str(allow_none=True)
    rejection_reason = fields.Str(allow_none=True)


class PaymentExecutionSchema(Schema):
    """Schema for executing payment."""
    payment_reference = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    actual_amount_paid = fields.Decimal(required=True, as_string=True, places=2)
    payment_date = fields.Date(required=True)
    payment_notes = fields.Str(allow_none=True)
    
    @validates('actual_amount_paid')
    def validate_amount(self, value):
        if value <= 0:
            raise ValidationError('Amount must be greater than zero')


class LedgerPostingSchema(Schema):
    """Schema for posting to ledger."""
    ledger_reference = fields.Str(required=True, validate=validate.Length(min=1, max=200))
    posting_notes = fields.Str(allow_none=True)
