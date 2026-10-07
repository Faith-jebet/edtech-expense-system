export default function StatusBadge({ status, priority }) {
  if (priority) {
    return (
      <span className={`badge ${priority === 'Urgent' ? 'badge-urgent' : 'badge-draft'}`}>
        {priority}
      </span>
    );
  }
  
  const statusClass = {
    'Draft': 'badge-draft',
    'Submitted': 'badge-submitted',
    'Verified': 'badge-verified',
    'Approved': 'badge-approved',
    'Rejected': 'badge-rejected',
    'Paid': 'badge-paid',
    'Proof Attached': 'badge-paid',
    'Posted': 'badge-posted',
    'Closed': 'badge-closed',
  }[status] || 'badge-draft';
  
  return <span className={`badge ${statusClass}`}>{status}</span>;
}
