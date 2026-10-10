import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { expenseRequests, reports } from '@/lib/api';
import StatusBadge from '@/components/StatusBadge';
import { formatCurrency, formatDate } from '@/lib/utils';
import { PlusCircle, Download } from 'lucide-react';
import { useState } from 'react';

export default function RequestListPage() {
  const [exporting, setExporting] = useState(false);
  
  const { data, isLoading } = useQuery({
    queryKey: ['expense-requests'],
    queryFn: async () => {
      const response = await expenseRequests.list();
      return response.data;
    },
  });
  
  const handleExportCSV = async () => {
    try {
      setExporting(true);
      const response = await reports.exportRequestsCSV();
      
      // Create download link
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `expense_requests_${new Date().toISOString().split('T')[0]}.csv`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Export failed:', error);
      alert('Failed to export data');
    } finally {
      setExporting(false);
    }
  };
  
  const handleExportPDF = async () => {
    try {
      setExporting(true);
      const response = await reports.exportRequestsPDF();
      
      // Create download link
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `expense_requests_${new Date().toISOString().split('T')[0]}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Export failed:', error);
      alert('Failed to export data');
    } finally {
      setExporting(false);
    }
  };
  
  if (isLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }
  
  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-serif font-semibold text-brand">All Requests</h1>
        <div className="flex gap-3">
          <div className="relative inline-block text-left">
            <button 
              className="btn-secondary flex items-center gap-2"
              disabled={exporting}
            >
              <Download size={18} />
              Export
            </button>
            <div className="absolute right-0 z-10 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 hidden group-hover:block">
              <div className="py-1">
                <button
                  onClick={handleExportCSV}
                  className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  disabled={exporting}
                >
                  Export as CSV
                </button>
                <button
                  onClick={handleExportPDF}
                  className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  disabled={exporting}
                >
                  Export as PDF
                </button>
              </div>
            </div>
          </div>
          <Link to="/requests/new" className="btn-accent flex items-center gap-2">
            <PlusCircle size={18} />
            New Request
          </Link>
        </div>
      </div>
      
      {/* Export buttons as separate buttons for now */}
      <div className="flex gap-3 mb-4">
        <button
          onClick={handleExportCSV}
          className="btn-secondary flex items-center gap-2"
          disabled={exporting}
        >
          <Download size={18} />
          {exporting ? 'Exporting...' : 'Export CSV'}
        </button>
        <button
          onClick={handleExportPDF}
          className="btn-secondary flex items-center gap-2"
          disabled={exporting}
        >
          <Download size={18} />
          {exporting ? 'Exporting...' : 'Export PDF'}
        </button>
      </div>
      
      <div className="card">
        {data?.requests?.length > 0 ? (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Requester</th>
                  <th>Project</th>
                  <th>Payee</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Created</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {data.requests.map((request) => (
                  <tr key={request.id}>
                    <td className="font-mono text-sm">{request.request_id}</td>
                    <td>{request.requester_name}</td>
                    <td>{request.project_name}</td>
                    <td>{request.payee_name}</td>
                    <td>{formatCurrency(request.total_amount, request.currency)}</td>
                    <td><StatusBadge status={request.status} /></td>
                    <td>{formatDate(request.created_at)}</td>
                    <td>
                      <Link
                        to={`/requests/${request.id}`}
                        state={{ from: '/requests' }}
                        className="text-brand hover:text-brand-dark text-sm font-medium"
                      >
                        View
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12 text-muted">
            <p>No requests found</p>
          </div>
        )}
      </div>
    </div>
  );
}
