import { useParams, useNavigate, useLocation, Link } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { expenseRequests } from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import StatusBadge from '@/components/StatusBadge';
import { formatCurrency, formatDateTime } from '@/lib/utils';
import toast from 'react-hot-toast';
import { ArrowLeft, CheckCircle, XCircle, Send, DollarSign, Upload, FileText, Download, AlertCircle } from 'lucide-react';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const paymentSchema = z.object({
  payment_reference: z.string().min(1, 'Payment reference is required'),
  actual_amount_paid: z.string().min(1, 'Amount is required'),
  payment_date: z.string().min(1, 'Payment date is required'),
  payment_notes: z.string().optional(),
});

const ledgerSchema = z.object({
  ledger_reference: z.string().min(1, 'Ledger reference is required'),
  posting_notes: z.string().optional(),
});

export default function RequestDetailPage() {
  const { id } = useParams();
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [showApprovalModal, setShowApprovalModal] = useState(false);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [showPostingModal, setShowPostingModal] = useState(false);
  const [decision, setDecision] = useState('Approved');
  const [comments, setComments] = useState('');
  const [uploadFile, setUploadFile] = useState(null);
  const [attachmentType, setAttachmentType] = useState('Proof of Payment');
  const [uploadDescription, setUploadDescription] = useState('');
  
  const { data: request, isLoading } = useQuery({
    queryKey: ['expense-request', id],
    queryFn: async () => {
      const response = await expenseRequests.get(id);
      return response.data;
    },
  });
  
  const {
    register: registerPayment,
    handleSubmit: handleSubmitPayment,
    formState: { errors: paymentErrors },
  } = useForm({
    resolver: zodResolver(paymentSchema),
    defaultValues: {
      payment_date: new Date().toISOString().split('T')[0],
    },
  });
  
  const {
    register: registerLedger,
    handleSubmit: handleSubmitLedger,
    formState: { errors: ledgerErrors },
  } = useForm({
    resolver: zodResolver(ledgerSchema),
  });
  
  const submitMutation = useMutation({
    mutationFn: () => expenseRequests.submit(id),
    onSuccess: () => {
      toast.success('Request submitted successfully');
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to submit');
    },
  });
  
  const verifyMutation = useMutation({
    mutationFn: (data) => expenseRequests.verify(id, data),
    onSuccess: () => {
      if (decision === 'Verified') {
        const nextManager = parseFloat(request?.total_amount_usd) <= 100 ? 'Operations Manager' : 
                            parseFloat(request?.total_amount_usd) <= 500 ? 'Director' : 
                            'Managing Director';
        toast.success(`Request verified successfully! Forwarded to ${nextManager} for approval.`);
      } else {
        toast.success('Request rejected');
      }
      setShowApprovalModal(false);
      setComments('');
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Action failed');
    },
  });
  
  const approveMutation = useMutation({
    mutationFn: (data) => expenseRequests.approve(id, data),
    onSuccess: () => {
      toast.success(decision === 'Approved' ? 'Request approved' : 'Request rejected');
      setShowApprovalModal(false);
      setComments('');
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Action failed');
    },
  });
  
  const paymentMutation = useMutation({
    mutationFn: (data) => expenseRequests.pay(id, data),
    onSuccess: () => {
      toast.success('Payment recorded successfully');
      setShowPaymentModal(false);
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Payment recording failed');
    },
  });
  
  const uploadMutation = useMutation({
    mutationFn: async () => {
      const formData = new FormData();
      formData.append('file', uploadFile);
      formData.append('attachment_type', attachmentType);
      formData.append('description', uploadDescription);
      return expenseRequests.uploadAttachment(id, formData);
    },
    onSuccess: () => {
      toast.success('File uploaded successfully');
      setShowUploadModal(false);
      setUploadFile(null);
      setUploadDescription('');
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Upload failed');
    },
  });
  
  const postingMutation = useMutation({
    mutationFn: (data) => expenseRequests.postToLedger(id, data),
    onSuccess: () => {
      toast.success('Posted to ledger successfully');
      setShowPostingModal(false);
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Posting failed');
    },
  });
  
  const closeMutation = useMutation({
    mutationFn: () => expenseRequests.close(id),
    onSuccess: () => {
      toast.success('Request closed successfully');
      queryClient.invalidateQueries(['expense-request', id]);
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to close request');
    },
  });
  
  const handleDownload = async (attachmentId, filename) => {
    try {
      const response = await expenseRequests.downloadAttachment(id, attachmentId);
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      toast.error('Failed to download file');
    }
  };
  
  const handleCashVoucher = async () => {
    try {
      const response = await expenseRequests.generateCashVoucher(id);
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `cash_voucher_${request.request_id}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
      toast.success('Cash voucher downloaded');
    } catch (error) {
      toast.error('Failed to generate cash voucher');
    }
  };
  
  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }
  
  if (!request) {
    return <div className="text-center py-12">Request not found</div>;
  }
  
  const canSubmit = request.status === 'Draft' && request.requester_id === user?.id;
  const canVerify = request.status === 'Submitted' && user?.role === 'Accountant' && request.requester_id !== user?.id;
  const canApprove = request.status === 'Verified' &&
    ['Director', 'Managing Director', 'Operation Manager', 'Operations Manager', 'Manager'].includes(user?.role) &&
    request.requester_id !== user?.id;
  const canPay = ['Approved', 'Partially Paid'].includes(request.status) && user?.role === 'Paying Officer' && request.requester_id !== user?.id;
  const canUploadProof = ['Paid', 'Partially Paid'].includes(request.status) && user?.role === 'Paying Officer' && request.requester_id !== user?.id;
  const canUploadSupportingDocument = ['Draft', 'Submitted', 'Rejected'].includes(request.status) &&
    request.requester_id === user?.id;
  const hasPaymentEvidence = request.attachments?.some(
    (attachment) => ['Receipt', 'Proof of Payment'].includes(attachment.attachment_type)
  );
  const canPost = request.status === 'Paid' && hasPaymentEvidence &&
    user?.role === 'Accountant' && request.requester_id !== user?.id;
  const canClose = request.status === 'Posted' && user?.role === 'Accountant' && request.requester_id !== user?.id;
  
  const location = useLocation();
  
  let defaultBack = '/requests';
  if (user?.role === 'Accountant') {
    defaultBack = ['Submitted', 'Paid'].includes(request.status) && request.requester_id !== user?.id ? '/my-tasks' : '/requests';
  } else if (['Director', 'Managing Director', 'Operation Manager', 'Operations Manager', 'Manager'].includes(user?.role)) {
    defaultBack = request.status === 'Verified' && request.requester_id !== user?.id ? '/my-tasks' : '/requests';
  } else if (user?.role === 'Paying Officer') {
    defaultBack = ['Approved', 'Partially Paid'].includes(request.status) && request.requester_id !== user?.id ? '/my-tasks' : '/requests';
  }

  const backPath = location.state?.from || defaultBack;
  
  let backText = 'Back';
  if (backPath === '/my-tasks') backText = 'Back to Tasks';
  else if (backPath === '/requests') backText = 'Back to Requests';
  else if (backPath === '/') backText = 'Back to Dashboard';

  return (
    <div>
      <Link to={backPath} className="inline-flex items-center gap-2 text-brand hover:text-brand-dark mb-4">
        <ArrowLeft size={18} />
        {backText}
      </Link>
      
      <div className="flex flex-col sm:flex-row justify-between items-start gap-4 mb-6">
        <div>
          <h1 className="text-3xl font-serif font-semibold text-brand">
            {request.request_id}
          </h1>
          <p className="text-muted mt-1">
            Requested by {request.requester_name} on {formatDateTime(request.created_at)}
          </p>
        </div>
        
        <div className="flex items-center gap-3 flex-wrap">
          <StatusBadge status={request.status} />
          {request.priority === 'Urgent' && <StatusBadge priority="Urgent" />}
          {request.is_overdue && (
            <span className="badge bg-red-100 text-danger">Overdue</span>
          )}
          {request.split_purchase_flag && (
            <span className="badge bg-yellow-100 text-accent">Split Purchase</span>
          )}
        </div>
      </div>
      
      {/* Split purchase warning */}
      {request.split_purchase_flag && (
        <div className="card mb-6 bg-yellow-50 border-yellow-200">
          <div className="flex items-start gap-3">
            <AlertCircle className="text-accent mt-1" size={20} />
            <div>
              <h3 className="font-semibold text-accent mb-1">Split Purchase Detected</h3>
              <p className="text-sm text-ink">{request.split_purchase_note}</p>
            </div>
          </div>
        </div>
      )}
      
      {/* Actions */}
      {(canSubmit || canVerify || canApprove || canPay || canUploadProof || canUploadSupportingDocument || canPost || canClose) && (
        <div className="card mb-6 bg-brand-light">
          <div className="flex flex-wrap gap-3">
            {canSubmit && (
              <button
                onClick={() => submitMutation.mutate()}
                disabled={submitMutation.isPending}
                className="btn-accent flex items-center gap-2"
              >
                <Send size={18} />
                Submit for Verification
              </button>
            )}
            
            {canVerify && (
              <>
                <button
                  onClick={() => {
                    setDecision('Verified');
                    setShowApprovalModal(true);
                  }}
                  className="btn-accent flex items-center gap-2"
                >
                  <CheckCircle size={18} />
                  Verify Request
                </button>
                <button
                  onClick={() => {
                    setDecision('Rejected');
                    setShowApprovalModal(true);
                  }}
                  className="btn-danger flex items-center gap-2"
                >
                  <XCircle size={18} />
                  Reject Request
                </button>
              </>
            )}
            
            {canApprove && (
              <>
                <button
                  onClick={() => {
                    setDecision('Approved');
                    setShowApprovalModal(true);
                  }}
                  className="btn-accent flex items-center gap-2"
                >
                  <CheckCircle size={18} />
                  Approve Request
                </button>
                <button
                  onClick={() => {
                    setDecision('Rejected');
                    setShowApprovalModal(true);
                  }}
                  className="btn-danger flex items-center gap-2"
                >
                  <XCircle size={18} />
                  Reject Request
                </button>
              </>
            )}
            
            {canPay && (
              <>
                <button
                  onClick={() => setShowPaymentModal(true)}
                  className="btn-accent flex items-center gap-2"
                >
                  <DollarSign size={18} />
                  Record Payment
                </button>
                <button
                  onClick={() => {
                    setDecision('Rejected');
                    setShowApprovalModal(true);
                  }}
                  className="btn-danger flex items-center gap-2"
                >
                  <XCircle size={18} />
                  Reject Request
                </button>
              </>
            )}
            
            {canUploadProof && (
              <button
                onClick={() => {
                  setAttachmentType('Proof of Payment');
                  setShowUploadModal(true);
                }}
                className="btn-accent flex items-center gap-2"
              >
                <Upload size={18} />
                Upload Payment Proof
              </button>
            )}

            {canUploadSupportingDocument && (
              <button
                onClick={() => {
                  setAttachmentType('Quotation');
                  setShowUploadModal(true);
                }}
                className="btn-outline flex items-center gap-2"
              >
                <Upload size={18} />
                Attach Quotation / Invoice
              </button>
            )}
            
            {canPost && (
              <button
                onClick={() => setShowPostingModal(true)}
                className="btn-accent flex items-center gap-2"
              >
                <FileText size={18} />
                Post to Ledger
              </button>
            )}
            
            {canClose && (
              <button
                onClick={() => {
                  if (confirm('Are you sure you want to close this request? This action finalizes the request.')) {
                    closeMutation.mutate();
                  }
                }}
                disabled={closeMutation.isPending}
                className="btn-primary flex items-center gap-2"
              >
                <CheckCircle size={18} />
                Close Request
              </button>
            )}
            
            {request.payment_method === 'Cash' && request.status !== 'Draft' && (
              <button
                onClick={handleCashVoucher}
                className="btn-outline flex items-center gap-2"
              >
                <Download size={18} />
                Cash Voucher
              </button>
            )}
          </div>
        </div>
      )}
      
      {/* Request Details */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          {/* Header Info */}
          <div className="card">
            <h2 className="text-xl font-serif font-semibold mb-4">Request Information</h2>
            <dl className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
              <div>
                <dt className="text-muted">Project</dt>
                <dd className="font-medium">{request.project_name}</dd>
              </div>
              <div>
                <dt className="text-muted">Category</dt>
                <dd className="font-medium">{request.category_name}</dd>
              </div>
              <div>
                <dt className="text-muted">Payee</dt>
                <dd className="font-medium">{request.payee_name}</dd>
              </div>
              <div>
                <dt className="text-muted">Payment Method</dt>
                <dd className="font-medium">{request.payment_method}</dd>
              </div>
              <div>
                <dt className="text-muted">Budget Status</dt>
                <dd className="font-medium">{request.budget_status}</dd>
              </div>
              {request.is_advance && (
                <div>
                  <dt className="text-muted">Advance Deadline</dt>
                  <dd className="font-medium">{new Date(request.advance_retirement_deadline).toLocaleDateString()}</dd>
                </div>
              )}
            </dl>
          </div>
          
          {/* Line Items */}
          <div className="card">
            <h2 className="text-xl font-serif font-semibold mb-4">Line Items</h2>
            <div className="table-container">
              <table className="table">
                <thead>
                  <tr>
                    <th>Description</th>
                    <th>Qty</th>
                    <th>Unit Cost</th>
                    <th>Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {request.items.map((item) => (
                    <tr key={item.id}>
                      <td>{item.description}</td>
                      <td>{item.quantity}</td>
                      <td>{formatCurrency(item.unit_cost, request.currency)}</td>
                      <td>{formatCurrency(item.amount, request.currency)}</td>
                    </tr>
                  ))}
                </tbody>
                <tfoot>
                  <tr>
                    <td colSpan="3" className="text-right font-semibold">Total:</td>
                    <td className="font-semibold">{formatCurrency(request.total_amount, request.currency)}</td>
                  </tr>
                  {request.currency !== 'USD' && (
                    <tr>
                      <td colSpan="3" className="text-right text-muted text-sm">USD Equivalent:</td>
                      <td className="text-muted text-sm">{formatCurrency(request.total_amount_usd, 'USD')}</td>
                    </tr>
                  )}
                </tfoot>
              </table>
            </div>
          </div>
          
          {/* Justification */}
          <div className="card">
            <h2 className="text-xl font-serif font-semibold mb-4">Business Justification</h2>
            <p className="text-ink whitespace-pre-wrap">{request.business_justification}</p>
          </div>
          
          {/* Attachments */}
          {request.attachments?.length > 0 && (
            <div className="card">
              <div className="flex justify-between items-center mb-4">
                <h2 className="text-xl font-serif font-semibold">Attachments</h2>
                
              </div>
              <div className="space-y-2">
                {request.attachments.map((attachment) => (
                  <div key={attachment.id} className="flex items-center justify-between p-3 border border-line rounded">
                    <div className="flex items-center gap-3">
                      <FileText size={20} className="text-brand" />
                      <div>
                        <p className="font-medium text-sm">{attachment.filename}</p>
                        <p className="text-xs text-muted">
                          {attachment.attachment_type} • {(attachment.filesize / 1024).toFixed(0)} KB
                        </p>
                      </div>
                    </div>
                    <button
                      onClick={() => handleDownload(attachment.id, attachment.filename)}
                      className="text-brand hover:text-brand-dark"
                    >
                      <Download size={18} />
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Payment Details */}
          {request.payments && request.payments.length > 0 && (
            <div className="card">
              <h2 className="text-xl font-serif font-semibold mb-4">Payment History</h2>
              
              <div className="overflow-x-auto">
                <table className="w-full text-sm text-left">
                  <thead className="bg-gray-50 border-b border-gray-100">
                    <tr>
                      <th className="py-2 px-3 font-medium text-muted">Date</th>
                      <th className="py-2 px-3 font-medium text-muted">Reference</th>
                      <th className="py-2 px-3 font-medium text-muted">Amount</th>
                      <th className="py-2 px-3 font-medium text-muted">Paid By</th>
                      <th className="py-2 px-3 font-medium text-muted">Ledger Ref</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {request.payments.map((payment, idx) => (
                      <tr key={idx} className="hover:bg-gray-50/50">
                        <td className="py-2 px-3">{new Date(payment.payment_date).toLocaleDateString()}</td>
                        <td className="py-2 px-3 font-mono text-xs">{payment.payment_reference}</td>
                        <td className="py-2 px-3 font-medium">{formatCurrency(payment.actual_amount_paid, request.currency)}</td>
                        <td className="py-2 px-3">{payment.paid_by_name}</td>
                        <td className="py-2 px-3 font-mono text-xs">{payment.ledger_reference || '-'}</td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot className="bg-gray-50 font-medium">
                    <tr>
                      <td colSpan="2" className="py-2 px-3 text-right">Total Paid:</td>
                      <td className="py-2 px-3 text-brand">{formatCurrency(request.actual_amount_paid || 0, request.currency)}</td>
                      <td colSpan="2"></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            </div>
          )}
        </div>
        
        {/* Sidebar */}
        <div className="space-y-6">
          {/* Workflow Progress */}
          <div className="card">
            <h3 className="font-serif font-semibold mb-4">Workflow Progress</h3>
            <div className="space-y-3 text-sm">
              {request.submitted_at && (
                <div className="flex justify-between">
                  <span className="text-muted">Submitted</span>
                  <span>{formatDateTime(request.submitted_at)}</span>
                </div>
              )}
              {request.verified_at && (
                <div className="flex flex-col">
                  <div className="flex justify-between">
                    <span className="text-muted">Verified</span>
                    <span>{formatDateTime(request.verified_at)}</span>
                  </div>
                  {request.verified_by_name && (
                    <span className="text-xs text-muted">by {request.verified_by_name}</span>
                  )}
                </div>
              )}
              {request.approved_at && (
                <div className="flex flex-col">
                  <div className="flex justify-between">
                    <span className="text-muted">Approved</span>
                    <span>{formatDateTime(request.approved_at)}</span>
                  </div>
                  {request.approved_by_name && (
                    <span className="text-xs text-muted">by {request.approved_by_name}</span>
                  )}
                </div>
              )}
              {request.paid_at && (
                <div className="flex flex-col">
                  <div className="flex justify-between">
                    <span className="text-muted">Paid</span>
                    <span>{formatDateTime(request.paid_at)}</span>
                  </div>
                  {request.paid_by_name && (
                    <span className="text-xs text-muted">by {request.paid_by_name}</span>
                  )}
                </div>
              )}
              {request.posted_at && (
                <div className="flex flex-col">
                  <div className="flex justify-between">
                    <span className="text-muted">Posted</span>
                    <span>{formatDateTime(request.posted_at)}</span>
                  </div>
                  {request.posted_by_name && (
                    <span className="text-xs text-muted">by {request.posted_by_name}</span>
                  )}
                </div>
              )}
              {request.closed_at && (
                <div className="flex flex-col">
                  <div className="flex justify-between">
                    <span className="text-muted">Closed</span>
                    <span>{formatDateTime(request.closed_at)}</span>
                  </div>
                  {request.closed_by_name && (
                    <span className="text-xs text-muted">by {request.closed_by_name}</span>
                  )}
                </div>
              )}
              {['Verified', 'Approved', 'Partially Paid', 'Paid', 'Posted', 'Closed'].includes(request.status) && (
                <div className="flex flex-col mt-2 pt-2 border-t border-gray-100">
                  <span className="text-muted text-xs">Designated Approver Group:</span>
                  <span className="font-medium text-brand text-sm">
                    {parseFloat(request.total_amount_usd) <= 100 ? 'Operations Manager / Manager' : 
                     parseFloat(request.total_amount_usd) <= 500 ? 'Director' : 
                     'Managing Director'}
                  </span>
                </div>
              )}
            </div>
          </div>
          
          {/* Approvals */}
          {request.approvals?.length > 0 && (
            <div className="card">
              <h3 className="font-serif font-semibold mb-4">Approval History</h3>
              <div className="space-y-3">
                {request.approvals.map((approval) => (
                  <div key={approval.id} className="border-l-2 border-brand pl-3">
                    <p className="font-medium text-sm">{approval.approver_name}</p>
                    <p className={`text-xs ${approval.decision === 'Approved' || approval.decision === 'Verified' ? 'text-success' : 'text-danger'}`}>
                      {approval.decision}
                    </p>
                    {approval.comments && (
                      <p className="text-xs mt-1">{approval.comments}</p>
                    )}
                    <p className="text-xs text-muted mt-1">{formatDateTime(approval.created_at).split(',')[0]}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          {/* Control Note */}
          <div className="card bg-brand-light">
            <p className="text-xs text-brand">
              <strong>Control Note:</strong> A request is not considered closed until payment evidence and the final accounting reference are attached.
            </p>
          </div>
        </div>
      </div>
      
      {/* Modals */}
      {/* Approval Modal - keeping existing code */}
      {showApprovalModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="card max-w-md w-full">
            <h3 className="text-xl font-serif font-semibold mb-4">
              {decision === 'Approved' ? 'Approve Request' : decision === 'Verified' ? 'Verify Request' : 'Reject Request'}
            </h3>
            
            <div className="mb-4">
              <label className="label">
                Comments {decision === 'Rejected' && <span className="text-danger">*</span>}
              </label>
              <textarea
                value={comments}
                onChange={(e) => setComments(e.target.value)}
                rows={4}
                className="input"
                placeholder={decision === 'Rejected' ? 'Please provide reason for rejection' : 'Optional comments...'}
              />
            </div>
            
            <div className="flex gap-3">
              <button
                onClick={() => {
                  if (decision === 'Rejected' && !comments.trim()) {
                    toast.error('Rejection reason is required');
                    return;
                  }
                  
                  const payload = {
                    decision,
                    comments: comments.trim(),
                    rejection_reason: decision === 'Rejected' ? comments.trim() : undefined,
                  };

                  if (decision === 'Verified') {
                    verifyMutation.mutate(payload);
                  } else if (decision === 'Rejected' && request.status === 'Submitted') {
                    // if it's an accountant rejecting a submitted request
                    verifyMutation.mutate(payload);
                  } else {
                    approveMutation.mutate(payload);
                  }
                }}
                disabled={approveMutation.isPending || verifyMutation.isPending}
                className={`btn flex-1 ${(decision === 'Approved' || decision === 'Verified') ? 'btn-accent' : 'btn-danger'}`}
              >
                {(approveMutation.isPending || verifyMutation.isPending) ? 'Processing...' : `Confirm ${decision}`}
              </button>
              <button
                onClick={() => {
                  setShowApprovalModal(false);
                  setComments('');
                }}
                className="btn-outline flex-1"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
      
      {/* Payment Modal */}
      {showPaymentModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="card max-w-md w-full">
            <h3 className="text-xl font-serif font-semibold mb-4">Record Payment</h3>
            
            <form onSubmit={handleSubmitPayment((data) => {
              const remaining = Number(request.total_amount) - Number(request.actual_amount_paid || 0);
              if (Number(data.actual_amount_paid) > remaining) {
                toast.error(`Amount cannot exceed the remaining balance (${remaining.toFixed(2)})`);
                return;
              }
              if (Number(data.actual_amount_paid) <= 0) {
                toast.error(`Amount must be greater than zero`);
                return;
              }
              paymentMutation.mutate(data);
            })} className="space-y-4">
              <div>
                <label className="label">
                  Payment Reference / Transaction ID <span className="text-danger">*</span>
                </label>
                <input
                  {...registerPayment('payment_reference')}
                  type="text"
                  className="input"
                  placeholder="e.g., TXN-20261006-001"
                />
                {paymentErrors.payment_reference && (
                  <p className="error-message">{paymentErrors.payment_reference.message}</p>
                )}
              </div>
              
              <div>
                <label className="label">
                  Amount to Pay <span className="text-danger">*</span>
                  <span className="text-xs text-muted ml-2">(Remaining: {(Number(request.total_amount) - Number(request.actual_amount_paid || 0)).toFixed(2)})</span>
                </label>
                <input
                  {...registerPayment('actual_amount_paid')}
                  type="number"
                  step="0.01"
                  className="input"
                  defaultValue={(Number(request.total_amount) - Number(request.actual_amount_paid || 0)).toFixed(2)}
                />
                {paymentErrors.actual_amount_paid && (
                  <p className="error-message">{paymentErrors.actual_amount_paid.message}</p>
                )}
              </div>
              
              <div>
                <label className="label">
                  Payment Date <span className="text-danger">*</span>
                </label>
                <input
                  {...registerPayment('payment_date')}
                  type="date"
                  className="input"
                />
                {paymentErrors.payment_date && (
                  <p className="error-message">{paymentErrors.payment_date.message}</p>
                )}
              </div>
              
              <div>
                <label className="label">Payment Notes</label>
                <textarea
                  {...registerPayment('payment_notes')}
                  rows={3}
                  className="input"
                  placeholder="Optional notes..."
                />
              </div>
              
              <div className="flex gap-3">
                <button
                  type="submit"
                  disabled={paymentMutation.isPending}
                  className="btn-accent flex-1"
                >
                  {paymentMutation.isPending ? 'Recording...' : 'Record Payment'}
                </button>
                <button
                  type="button"
                  onClick={() => setShowPaymentModal(false)}
                  className="btn-outline flex-1"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      
      {/* Upload Modal */}
      {showUploadModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="card max-w-md w-full">
            <h3 className="text-xl font-serif font-semibold mb-4">Upload Document</h3>
            
            <div className="space-y-4">
              <div>
                <label className="label">Document Type <span className="text-danger">*</span></label>
                <select
                    value={attachmentType}
                    onChange={(e) => setAttachmentType(e.target.value)}
                    className="input"
                  >
                    {canUploadProof ? (
                      <>
                        <option value="Proof of Payment">Proof of Payment</option>
                        <option value="Receipt">Receipt</option>
                        <option value="Cash Voucher">Cash Voucher</option>
                      </>
                    ) : (
                      <>
                        <option value="Quotation">Quotation</option>
                        <option value="Invoice">Invoice</option>
                      </>
                    )}
                  </select>
              </div>
              
              <div>
                <label className="label">File <span className="text-danger">*</span></label>
                <input
                  type="file"
                  onChange={(e) => setUploadFile(e.target.files[0])}
                  className="input"
                  accept=".pdf,.png,.jpg,.jpeg,.doc,.docx,.xls,.xlsx"
                />
                <p className="text-xs text-muted mt-1">
                  Max 10MB. Allowed: PDF, images, Word, Excel
                </p>
              </div>
              
              <div>
                <label className="label">Description</label>
                <textarea
                  value={uploadDescription}
                  onChange={(e) => setUploadDescription(e.target.value)}
                  rows={2}
                  className="input"
                  placeholder="Optional description..."
                />
              </div>
              
              <div className="flex gap-3">
                <button
                  onClick={() => {
                    if (!uploadFile) {
                      toast.error('Please select a file');
                      return;
                    }
                    uploadMutation.mutate();
                  }}
                  disabled={uploadMutation.isPending || !uploadFile}
                  className="btn-accent flex-1"
                >
                  {uploadMutation.isPending ? 'Uploading...' : 'Upload'}
                </button>
                <button
                  onClick={() => {
                    setShowUploadModal(false);
                    setUploadFile(null);
                    setUploadDescription('');
                  }}
                  className="btn-outline flex-1"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      
      {/* Posting Modal */}
      {showPostingModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="card max-w-md w-full">
            <h3 className="text-xl font-serif font-semibold mb-4">Post to Ledger</h3>
            
            <form onSubmit={handleSubmitLedger((data) => postingMutation.mutate(data))} className="space-y-4">
              <div>
                <label className="label">
                  Ledger / Accounting Reference <span className="text-danger">*</span>
                </label>
                <input
                  {...registerLedger('ledger_reference')}
                  type="text"
                  className="input"
                  placeholder="e.g., LED-2026-10-123"
                />
                {ledgerErrors.ledger_reference && (
                  <p className="error-message">{ledgerErrors.ledger_reference.message}</p>
                )}
              </div>
              
              <div>
                <label className="label">Posting Notes</label>
                <textarea
                  {...registerLedger('posting_notes')}
                  rows={3}
                  className="input"
                  placeholder="Optional notes..."
                />
              </div>
              
              <div className="flex gap-3">
                <button
                  type="submit"
                  disabled={postingMutation.isPending}
                  className="btn-accent flex-1"
                >
                  {postingMutation.isPending ? 'Posting...' : 'Post to Ledger'}
                </button>
                <button
                  type="button"
                  onClick={() => setShowPostingModal(false)}
                  className="btn-outline flex-1"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
