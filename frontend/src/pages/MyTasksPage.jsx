import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { expenseRequests } from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import StatusBadge from '@/components/StatusBadge';
import { formatCurrency, formatDate } from '@/lib/utils';

export default function MyTasksPage() {
  const { user } = useAuth();
  
  const { data: tasks, isLoading } = useQuery({
    queryKey: ['my-tasks'],
    queryFn: async () => {
      const response = await expenseRequests.myTasks();
      return response.data;
    },
  });
  
  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }
  
  return (
    <div>
      <h1 className="text-3xl font-serif font-semibold text-brand mb-8">My Tasks</h1>
      
      {/* Pending Verification */}
      {tasks?.pending_verification?.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-xl font-serif font-semibold mb-4">
            Pending Verification ({tasks.pending_verification.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Requester</th>
                  <th>Category</th>
                  <th>Amount</th>
                  <th>Submitted</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {tasks.pending_verification.map((req) => (
                  <tr key={req.id}>
                    <td className="font-mono text-sm">{req.request_id}</td>
                    <td>{req.requester_name}</td>
                    <td>{req.items?.[0]?.category_name || 'N/A'}</td>
                    <td>{formatCurrency(req.total_amount, req.currency)}</td>
                    <td>{formatDate(req.submitted_at)}</td>
                    <td>
                      <Link to={`/requests/${req.id}`} className="btn-primary text-sm">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
      
      {/* Pending Approval */}
      {tasks?.pending_approval?.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-xl font-serif font-semibold mb-4">
            Pending Your Approval ({tasks.pending_approval.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Requester</th>
                  <th>Category</th>
                  <th>Amount (USD)</th>
                  <th>Verified</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {tasks.pending_approval.map((req) => (
                  <tr key={req.id}>
                    <td className="font-mono text-sm">{req.request_id}</td>
                    <td>{req.requester_name}</td>
                    <td>{req.items?.[0]?.category_name || 'N/A'}</td>
                    <td>{formatCurrency(req.total_amount_usd, 'USD')}</td>
                    <td>{formatDate(req.verified_at)}</td>
                    <td>
                      <Link to={`/requests/${req.id}`} className="btn-accent text-sm">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
      
      {/* Pending Payment */}
      {tasks?.pending_payment?.length > 0 && (
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">
            Pending Payment ({tasks.pending_payment.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Payee</th>
                  <th>Category</th>
                  <th>Amount</th>
                  <th>Approved</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {tasks.pending_payment.map((req) => (
                  <tr key={req.id}>
                    <td className="font-mono text-sm">{req.request_id}</td>
                    <td>{req.payee_name}</td>
                    <td>{req.items?.[0]?.category_name || 'N/A'}</td>
                    <td>{formatCurrency(req.total_amount, req.currency)}</td>
                    <td>{formatDate(req.approved_at)}</td>
                    <td>
                      <Link to={`/requests/${req.id}`} className="btn-primary text-sm">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Pending Posting */}
      {tasks?.pending_posting?.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-xl font-serif font-semibold mb-4">
            Pending Ledger Posting ({tasks.pending_posting.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Payee</th>
                  <th>Category</th>
                  <th>Amount</th>
                  <th>Paid</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {tasks.pending_posting.map((req) => (
                  <tr key={req.id}>
                    <td className="font-mono text-sm">{req.request_id}</td>
                    <td>{req.payee_name}</td>
                    <td>{req.items?.[0]?.category_name || 'N/A'}</td>
                    <td>{formatCurrency(req.total_amount, req.currency)}</td>
                    <td>{formatDate(req.paid_at)}</td>
                    <td>
                      <Link to={`/requests/${req.id}`} className="btn-primary text-sm">
                        Review
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
      
      {!tasks?.pending_verification?.length && 
       !tasks?.pending_approval?.length && 
       !tasks?.pending_payment?.length &&
       !tasks?.pending_posting?.length && (
        <div className="card text-center py-12 text-muted">
          <p>No pending tasks</p>
        </div>
      )}
    </div>
  );
}
