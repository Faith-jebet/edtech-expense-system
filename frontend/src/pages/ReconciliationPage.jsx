import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { reconciliations } from '@/lib/api';
import { formatCurrency, formatDate } from '@/lib/utils';
import { useAuth } from '@/contexts/AuthContext';
import { PlusCircle, X } from 'lucide-react';
import toast from 'react-hot-toast';

export default function ReconciliationPage() {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  
  const [formData, setFormData] = useState({
    account_type: 'Bank',
    account_name: '',
    account_number: '',
    period_start: '',
    period_end: '',
    opening_balance: '',
    system_closing_balance: '',
    actual_closing_balance: ''
  });
  
  const { data, isLoading } = useQuery({
    queryKey: ['reconciliations'],
    queryFn: async () => {
      const response = await reconciliations.list();
      return response.data;
    },
  });

  const createMutation = useMutation({
    mutationFn: async (payload) => {
      return await reconciliations.create(payload);
    },
    onSuccess: () => {
      toast.success('Reconciliation created successfully');
      setShowModal(false);
      queryClient.invalidateQueries(['reconciliations']);
      setFormData({
        account_type: 'Bank',
        account_name: '',
        account_number: '',
        period_start: '',
        period_end: '',
        opening_balance: '',
        system_closing_balance: '',
        actual_closing_balance: ''
      });
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to create reconciliation');
    }
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.account_name || !formData.period_start || !formData.period_end || 
        formData.opening_balance === '' || formData.system_closing_balance === '' || formData.actual_closing_balance === '') {
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
        <h1 className="text-3xl font-serif font-semibold text-brand">Reconciliations</h1>
        {user?.role === 'Accountant' && (
          <button 
            onClick={() => setShowModal(true)}
            className="btn-accent flex items-center gap-2"
          >
            <PlusCircle size={18} />
            New Reconciliation
          </button>
        )}
      </div>
      
      <div className="card">
        {data?.reconciliations?.length > 0 ? (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Account</th>
                  <th>Period</th>
                  <th>Status</th>
                  <th>System Bal</th>
                  <th>Actual Bal</th>
                  <th>Difference</th>
                  <th>Prepared By</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {data.reconciliations.map((recon) => (
                  <tr key={recon.id}>
                    <td>
                      <div className="font-medium text-ink">{recon.account_name}</div>
                      <div className="text-xs text-muted">{recon.account_type} {recon.account_number ? `- ${recon.account_number}` : ''}</div>
                    </td>
                    <td className="text-sm">
                      {formatDate(recon.period_start)} to {formatDate(recon.period_end)}
                    </td>
                    <td>
                      <span className={`badge ${
                        recon.status === 'Reconciled' ? 'badge-success' :
                        recon.status === 'Discrepancy' ? 'badge-danger' : 'badge-warning'
                      }`}>
                        {recon.status}
                      </span>
                    </td>
                    <td className="font-mono text-sm">{formatCurrency(recon.system_closing_balance)}</td>
                    <td className="font-mono text-sm">{formatCurrency(recon.actual_closing_balance)}</td>
                    <td className={`font-mono text-sm font-medium ${
                      parseFloat(recon.difference) === 0 ? 'text-emerald-600' : 'text-danger'
                    }`}>
                      {formatCurrency(recon.difference)}
                    </td>
                    <td className="text-sm">{recon.prepared_by_name}</td>
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
            <p>No reconciliations found</p>
          </div>
        )}
      </div>

      {/* Create Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-2xl overflow-hidden">
            <div className="flex justify-between items-center p-6 border-b border-line">
              <h3 className="text-xl font-serif font-semibold text-brand">New Reconciliation</h3>
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
                  <label className="label">Account Type <span className="text-danger">*</span></label>
                  <select
                    required
                    className="input"
                    value={formData.account_type}
                    onChange={(e) => setFormData({...formData, account_type: e.target.value})}
                  >
                    <option value="Bank">Bank</option>
                    <option value="Mobile Money">Mobile Money</option>
                    <option value="Petty Cash">Petty Cash</option>
                  </select>
                </div>
                
                <div>
                  <label className="label">Account Name <span className="text-danger">*</span></label>
                  <input
                    type="text"
                    required
                    className="input"
                    value={formData.account_name}
                    onChange={(e) => setFormData({...formData, account_name: e.target.value})}
                    placeholder="e.g. KCB Operations Account"
                  />
                </div>

                <div>
                  <label className="label">Account Number</label>
                  <input
                    type="text"
                    className="input"
                    value={formData.account_number}
                    onChange={(e) => setFormData({...formData, account_number: e.target.value})}
                    placeholder="e.g. 1234567890"
                  />
                </div>

                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="label">Period Start <span className="text-danger">*</span></label>
                    <input
                      type="date"
                      required
                      className="input"
                      value={formData.period_start}
                      onChange={(e) => setFormData({...formData, period_start: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="label">Period End <span className="text-danger">*</span></label>
                    <input
                      type="date"
                      required
                      className="input"
                      value={formData.period_end}
                      onChange={(e) => setFormData({...formData, period_end: e.target.value})}
                    />
                  </div>
                </div>

                <div>
                  <label className="label">Opening Balance (USD) <span className="text-danger">*</span></label>
                  <input
                    type="number"
                    required
                    step="0.01"
                    className="input"
                    value={formData.opening_balance}
                    onChange={(e) => setFormData({...formData, opening_balance: e.target.value})}
                    placeholder="0.00"
                  />
                </div>

                <div>
                  <label className="label">System Closing Bal (USD) <span className="text-danger">*</span></label>
                  <input
                    type="number"
                    required
                    step="0.01"
                    className="input"
                    value={formData.system_closing_balance}
                    onChange={(e) => setFormData({...formData, system_closing_balance: e.target.value})}
                    placeholder="0.00"
                  />
                </div>

                <div>
                  <label className="label">Actual Statement Bal (USD) <span className="text-danger">*</span></label>
                  <input
                    type="number"
                    required
                    step="0.01"
                    className="input"
                    value={formData.actual_closing_balance}
                    onChange={(e) => setFormData({...formData, actual_closing_balance: e.target.value})}
                    placeholder="0.00"
                  />
                </div>
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
                  {createMutation.isPending ? 'Saving...' : 'Create Reconciliation'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
