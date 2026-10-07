import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { incomeReceipts, projects } from '@/lib/api';
import { formatCurrency, formatDate } from '@/lib/utils';
import { useAuth } from '@/contexts/AuthContext';
import { PlusCircle, X } from 'lucide-react';
import toast from 'react-hot-toast';

export default function IncomeReceiptsPage() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  
  const [formData, setFormData] = useState({
    source: '',
    project_id: '',
    description: '',
    currency: 'USD',
    amount: '',
    payment_method: 'Bank Transfer',
    reference_number: '',
    receipt_date: new Date().toISOString().split('T')[0]
  });
  
  const { data, isLoading } = useQuery({
    queryKey: ['income-receipts'],
    queryFn: async () => {
      const response = await incomeReceipts.list();
      return response.data;
    },
  });

  const { data: projectsData } = useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      const response = await projects.list();
      return response.data;
    },
  });
  
  const createMutation = useMutation({
    mutationFn: async (data) => {
      const payload = {
        ...data,
        project_id: parseInt(data.project_id),
        amount: parseFloat(data.amount)
      };
      return await incomeReceipts.create(payload);
    },
    onSuccess: () => {
      toast.success('Income receipt created successfully');
      setShowModal(false);
      queryClient.invalidateQueries(['income-receipts']);
      setFormData({
        source: '',
        project_id: '',
        description: '',
        currency: 'USD',
        amount: '',
        payment_method: 'Bank Transfer',
        reference_number: '',
        receipt_date: new Date().toISOString().split('T')[0]
      });
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to create receipt');
    }
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.project_id || !formData.amount || !formData.source) {
      toast.error('Please fill in all required fields');
      return;
    }
    createMutation.mutate(formData);
  };
  
  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }
  
  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-serif font-semibold text-brand">Income Receipts</h1>
        {user?.role === 'Accountant' && (
          <button 
            onClick={() => setShowModal(true)}
            className="btn-accent flex items-center gap-2"
          >
            <PlusCircle size={18} />
            New Income Receipt
          </button>
        )}
      </div>
      
      <div className="card">
        {data?.receipts?.length > 0 ? (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Receipt ID</th>
                  <th>Source</th>
                  <th>Project</th>
                  <th>Amount</th>
                  <th>Date</th>
                  <th>Recorded By</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {data.receipts.map((receipt) => (
                  <tr key={receipt.id}>
                    <td className="font-mono text-sm font-medium">{receipt.receipt_id}</td>
                    <td>{receipt.source}</td>
                    <td>{receipt.project_name}</td>
                    <td className="font-medium text-emerald-600">{formatCurrency(receipt.amount, receipt.currency)}</td>
                    <td>{formatDate(receipt.receipt_date)}</td>
                    <td className="text-sm">{receipt.recorded_by_name}</td>
                    <td>
                      <button className="text-brand hover:text-brand-dark text-sm">
                        View
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12 text-muted">
            <p>No income receipts found</p>
          </div>
        )}
      </div>

      {/* Create Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl overflow-hidden">
            <div className="flex justify-between items-center p-6 border-b border-line">
              <h3 className="text-xl font-serif font-semibold text-brand">Record Income Receipt</h3>
              <button 
                onClick={() => setShowModal(false)}
                className="text-muted hover:text-ink transition-colors"
              >
                <X size={24} />
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                  <label className="label">Source (Donor/Client) <span className="text-danger">*</span></label>
                  <input
                    type="text"
                    required
                    className="input"
                    value={formData.source}
                    onChange={(e) => setFormData({...formData, source: e.target.value})}
                    placeholder="e.g. World Bank Grant"
                  />
                </div>
                
                <div>
                  <label className="label">Project <span className="text-danger">*</span></label>
                  <select
                    required
                    className="input"
                    value={formData.project_id}
                    onChange={(e) => setFormData({...formData, project_id: e.target.value})}
                  >
                    <option value="">Select a project...</option>
                    {projectsData?.projects?.map(p => (
                      <option key={p.id} value={p.id}>{p.project_code} - {p.name}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="label">Amount <span className="text-danger">*</span></label>
                  <div className="flex gap-2">
                    <select
                      className="input w-1/3"
                      value={formData.currency}
                      onChange={(e) => setFormData({...formData, currency: e.target.value})}
                    >
                      <option value="USD">USD</option>
                      <option value="KES">KES</option>
                      <option value="EUR">EUR</option>
                      <option value="GBP">GBP</option>
                    </select>
                    <input
                      type="number"
                      required
                      min="0.01"
                      step="0.01"
                      className="input w-2/3"
                      value={formData.amount}
                      onChange={(e) => setFormData({...formData, amount: e.target.value})}
                      placeholder="0.00"
                    />
                  </div>
                </div>

                <div>
                  <label className="label">Receipt Date <span className="text-danger">*</span></label>
                  <input
                    type="date"
                    required
                    className="input"
                    value={formData.receipt_date}
                    onChange={(e) => setFormData({...formData, receipt_date: e.target.value})}
                  />
                </div>

                <div>
                  <label className="label">Payment Method <span className="text-danger">*</span></label>
                  <select
                    required
                    className="input"
                    value={formData.payment_method}
                    onChange={(e) => setFormData({...formData, payment_method: e.target.value})}
                  >
                    <option value="Bank Transfer">Bank Transfer</option>
                    <option value="Check">Check</option>
                    <option value="Cash">Cash</option>
                    <option value="Mobile Money">Mobile Money</option>
                  </select>
                </div>

                <div>
                  <label className="label">Reference Number</label>
                  <input
                    type="text"
                    className="input"
                    value={formData.reference_number}
                    onChange={(e) => setFormData({...formData, reference_number: e.target.value})}
                    placeholder="e.g. Bank Ref #123"
                  />
                </div>
              </div>

              <div className="mb-8">
                <label className="label">Description <span className="text-danger">*</span></label>
                <textarea
                  required
                  rows={2}
                  className="input"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  placeholder="Details about this income..."
                />
              </div>

              <div className="flex justify-end gap-3 pt-4 border-t border-line">
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="btn-outline"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={createMutation.isPending}
                  className="btn-accent"
                >
                  {createMutation.isPending ? 'Saving...' : 'Record Income'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
