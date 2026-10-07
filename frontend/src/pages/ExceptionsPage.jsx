import { useQuery } from '@tanstack/react-query';
import { reconciliations } from '@/lib/api';
import { formatCurrency, formatDate } from '@/lib/utils';
import { AlertTriangle } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function ExceptionsPage() {
  const { data: exceptions, isLoading } = useQuery({
    queryKey: ['exceptions'],
    queryFn: async () => {
      const response = await reconciliations.exceptions();
      return response.data;
    },
  });
  
  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }
  
  const totalExceptions = (exceptions?.unreconciled_differences?.length || 0) +
                         (exceptions?.overdue_advances?.length || 0) +
                         (exceptions?.missing_receipts?.length || 0);
  
  return (
    <div>
      <div className="flex items-center gap-3 mb-8">
        <AlertTriangle className="text-danger" size={32} />
        <div>
          <h1 className="text-3xl font-serif font-semibold text-brand">Exception Report</h1>
          <p className="text-muted mt-1">
            {totalExceptions} exception(s) requiring attention
          </p>
        </div>
      </div>
      
      {/* Unreconciled Differences */}
      {exceptions?.unreconciled_differences?.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-xl font-serif font-semibold mb-4 text-danger">
            Unreconciled Differences ({exceptions.unreconciled_differences.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Account</th>
                  <th>Type</th>
                  <th>Period End</th>
                  <th>Difference</th>
                  <th>Prepared By</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {exceptions.unreconciled_differences.map((item) => (
                  <tr key={item.id}>
                    <td className="font-medium">{item.account_name}</td>
                    <td>{item.account_type}</td>
                    <td>{formatDate(item.period_end)}</td>
                    <td className="font-semibold text-danger">
                      {formatCurrency(item.difference, 'USD')}
                    </td>
                    <td>{item.prepared_by}</td>
                    <td>
                      <Link to="/reconciliations" className="text-brand hover:text-brand-dark text-sm">
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
      
      {/* Overdue Advances */}
      {exceptions?.overdue_advances?.length > 0 && (
        <div className="card mb-6">
          <h2 className="text-xl font-serif font-semibold mb-4 text-danger">
            Overdue Advances ({exceptions.overdue_advances.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Requester</th>
                  <th>Amount</th>
                  <th>Deadline</th>
                  <th>Days Overdue</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {exceptions.overdue_advances.map((item) => (
                  <tr key={item.id}>
                    <td className="font-mono text-sm">{item.request_id}</td>
                    <td>{item.requester}</td>
                    <td>{formatCurrency(item.amount, 'USD')}</td>
                    <td>{formatDate(item.deadline)}</td>
                    <td className="font-semibold text-danger">{item.days_overdue}</td>
                    <td>
                      <Link to={`/requests/${item.id}`} className="text-brand hover:text-brand-dark text-sm">
                        View
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
      
      {/* Missing Receipts */}
      {exceptions?.missing_receipts?.length > 0 && (
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4 text-danger">
            Missing Payment Receipts ({exceptions.missing_receipts.length})
          </h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Payee</th>
                  <th>Amount</th>
                  <th>Paid At</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {exceptions.missing_receipts.map((item) => (
                  <tr key={item.id}>
                    <td className="font-mono text-sm">{item.request_id}</td>
                    <td>{item.payee}</td>
                    <td>{formatCurrency(item.amount, 'USD')}</td>
                    <td>{formatDate(item.paid_at)}</td>
                    <td>
                      <Link to={`/requests/${item.id}`} className="text-brand hover:text-brand-dark text-sm">
                        Add Receipt
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
      
      {totalExceptions === 0 && (
        <div className="card text-center py-12">
          <p className="text-success font-semibold">✓ No exceptions found</p>
          <p className="text-muted mt-2">All reconciliations are complete and all advances are retired</p>
        </div>
      )}
    </div>
  );
}
