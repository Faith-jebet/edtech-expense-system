import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useQuery } from '@tanstack/react-query';
import { reports, expenseRequests } from '@/lib/api';
import { PlusCircle, Settings, FileText, Clock, CheckCircle, AlertCircle, TrendingUp, DollarSign } from 'lucide-react';
import StatusBadge from '@/components/StatusBadge';
import { formatCurrency, formatDate } from '@/lib/utils';
import { Link } from 'react-router-dom';
import AdminDashboard from '@/pages/AdminDashboard';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  BarChart, Bar, Cell, PieChart, Pie, Legend
} from 'recharts';

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#0ea5e9', '#ec4899', '#14b8a6', '#f97316', '#6366f1'];

export default function Dashboard() {
  const { user } = useAuth();
  const [period, setPeriod] = useState('all_time');

  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ['dashboard-stats', period],
    queryFn: async () => {
      const response = await reports.dashboardStats(`?period=${period}`);
      return response.data;
    },
  });

  const { data: recentRequests, isLoading: requestsLoading } = useQuery({
    queryKey: ['expense-requests', 'recent'],
    queryFn: async () => {
      const response = await expenseRequests.list('?limit=5');
      return response.data.requests;
    },
  });

  if (statsLoading || requestsLoading) {
    return <div className="text-center py-12">Loading...</div>;
  }



  // Format data for charts
  const categoryData = stats?.category_spending?.map(item => ({
    name: item.name,
    value: parseFloat(item.total)
  })) || [];

  const projectData = stats?.project_spending?.map(item => ({
    name: item.name,
    value: parseFloat(item.total)
  })) || [];

  const trendData = stats?.expenses_over_time?.map(item => ({
    date: new Date(item.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
    amount: parseFloat(item.total)
  })) || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header & Filter */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-serif font-bold text-ink">Dashboard</h1>
          <p className="text-muted text-sm mt-1">
            Welcome back, {user?.full_name}. 
            {stats?.my_tasks > 0 ? (
              <span className="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                You have {stats.my_tasks} task{stats.my_tasks !== 1 ? 's' : ''} requiring your attention
              </span>
            ) : (
              <span className="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                All caught up! No pending tasks.
              </span>
            )}
          </p>
        </div>
        
        <div className="flex items-center gap-4">
          <select 
            value={period} 
            onChange={(e) => setPeriod(e.target.value)}
            className="input w-auto min-w-[150px] font-medium text-sm"
          >
            <option value="today">Today</option>
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="this_month">This month</option>
            <option value="this_quarter">This quarter</option>
            <option value="all_time">All Time</option>
          </select>

          {['Operation Manager'].includes(user?.role) && (
            <Link to="/requests/new" className="btn-accent flex items-center gap-2">
              <PlusCircle size={18} />
              New Request
            </Link>
          )}
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        <div className="card border-l-4 border-l-brand">
          <p className="text-sm font-medium text-muted">Total Expenses</p>
          <div className="mt-2 flex items-baseline gap-2">
            <h2 className="text-2xl sm:text-3xl font-bold text-ink truncate" title={formatCurrency(stats?.total_expenses || 0)}>
              {formatCurrency(stats?.total_expenses || 0)}
            </h2>
          </div>
          <p className="text-xs text-muted mt-2">Completed expenditure</p>
        </div>
        
        <div className="card border-l-4 border-l-amber-500">
          <div className="flex justify-between items-start">
            <p className="text-sm font-medium text-muted">Pending Amount</p>
            {stats?.my_tasks > 0 && (
              <Link to="/my-tasks" className="px-2 py-0.5 rounded-full bg-amber-100 text-amber-800 text-xs font-bold hover:bg-amber-200 transition-colors">
                {stats.my_tasks} Action{stats.my_tasks !== 1 ? 's' : ''} Required
              </Link>
            )}
          </div>
          <div className="mt-2 flex items-baseline gap-2">
            <h2 className="text-2xl sm:text-3xl font-bold text-ink truncate" title={formatCurrency(stats?.pending_amount || 0)}>
              {formatCurrency(stats?.pending_amount || 0)}
            </h2>
          </div>
          <p className="text-xs text-muted mt-2">
            Across {stats?.pending_requests || 0} total pending request{stats?.pending_requests !== 1 ? 's' : ''}
          </p>
        </div>

        <div className="card border-l-4 border-l-blue-500">
          <p className="text-sm font-medium text-muted">Approved Expenses</p>
          <div className="mt-2 flex items-baseline gap-2">
            <h2 className="text-2xl sm:text-3xl font-bold text-ink truncate" title={formatCurrency(stats?.approved_expenses || 0)}>
              {formatCurrency(stats?.approved_expenses || 0)}
            </h2>
          </div>
          <p className="text-xs text-muted mt-2">All approved expenditure</p>
        </div>

        <div className="card border-l-4 border-l-emerald-500">
          <p className="text-sm font-medium text-muted">Remaining Budget</p>
          <div className="mt-2 flex items-baseline gap-2">
            <h2 className="text-2xl sm:text-3xl font-bold text-ink truncate" title={formatCurrency(stats?.remaining_budget || 0)}>
              {formatCurrency(stats?.remaining_budget || 0)}
            </h2>
          </div>
          <p className="text-xs text-muted mt-2">Unutilized allocations</p>
        </div>
      </div>

      {/* Charts Row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Expenses Over Time */}
        <div className="card min-w-0">
          <h2 className="text-lg font-bold text-ink mb-6">Expenses Over Time</h2>
          <div className="h-64 w-full">
            {trendData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={trendData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                  <defs>
                    <linearGradient id="colorAmount" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#0f172a" stopOpacity={0.3}/>
                      <stop offset="95%" stopColor="#0f172a" stopOpacity={0}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                  <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#64748b'}} />
                  <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#64748b'}} tickFormatter={(val) => `$${val}`} />
                  <Tooltip formatter={(value) => formatCurrency(value)} />
                  <Area type="monotone" dataKey="amount" stroke="#0f172a" strokeWidth={2} fillOpacity={1} fill="url(#colorAmount)" />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-muted">No trend data available</div>
            )}
          </div>
        </div>

        {/* Spending by Category */}
        <div className="card min-w-0">
          <h2 className="text-lg font-bold text-ink mb-6">Spending by Category</h2>
          <div className="h-64 w-full">
            {categoryData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={categoryData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {categoryData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => formatCurrency(value)} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-muted">No category data available</div>
            )}
          </div>
        </div>
      </div>

      {/* Charts Row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Spending by Project */}
        <div className="card min-w-0">
          <h2 className="text-lg font-bold text-ink mb-6">Spending by Project</h2>
          <div className="h-64 w-full">
            {projectData.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={projectData} layout="vertical" margin={{ top: 0, right: 30, left: 20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" horizontal={true} vertical={false} stroke="#e2e8f0" />
                  <XAxis type="number" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#64748b'}} />
                  <YAxis dataKey="name" type="category" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#64748b'}} width={100} />
                  <Tooltip formatter={(value) => formatCurrency(value)} />
                  <Bar dataKey="value" fill="#3b82f6" radius={[0, 4, 4, 0]} barSize={24} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-full flex items-center justify-center text-muted">No project data available</div>
            )}
          </div>
        </div>

        {/* Budget Utilization */}
        <div className="card min-w-0">
          <h2 className="text-lg font-bold text-ink mb-6">Budget Utilization</h2>
          <div className="space-y-6">
            <div className="flex justify-between items-end">
              <div>
                <p className="text-sm font-medium text-muted">Total Allocated</p>
                <p className="text-xl font-bold text-ink mt-1">{formatCurrency(stats?.total_budget || 0)}</p>
              </div>
              <div className="text-right">
                <p className="text-sm font-medium text-muted">Total Spent (All Time)</p>
                <p className="text-xl font-bold text-ink mt-1">{formatCurrency(stats?.all_time_spent || 0)}</p>
              </div>
            </div>
            
            <div>
              <div className="flex justify-between text-sm mb-2 font-medium">
                <span className="text-brand">Utilization</span>
                <span className="text-ink">
                  {stats?.total_budget > 0 
                    ? Math.min(100, Math.round((stats?.all_time_spent / stats?.total_budget) * 100)) 
                    : 0}%
                </span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-3">
                <div 
                  className="bg-brand h-3 rounded-full transition-all" 
                  style={{ width: `${stats?.total_budget > 0 ? Math.min(100, Math.round((stats?.all_time_spent / stats?.total_budget) * 100)) : 0}%` }}
                ></div>
              </div>
            </div>

            <div className="pt-4 border-t border-line">
              <div className="flex justify-between">
                <span className="text-sm font-medium text-gray-700">Remaining Available:</span>
                <span className="text-sm font-bold text-emerald-600">{formatCurrency(stats?.remaining_budget || 0)}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Role Tasks Summary */}
      <div className="card min-w-0 mb-6">
        <h2 className="text-xl font-serif font-semibold text-ink mb-6">
          Pending Tasks by Role
        </h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
          {stats?.role_tasks && Object.entries(stats.role_tasks).map(([role, count]) => (
            <div key={role} className="bg-gray-50 rounded-lg p-4 border border-line flex flex-col items-center text-center">
              <span className="text-sm font-medium text-muted mb-2">{role}</span>
              <span className={`text-2xl font-bold ${count > 0 ? 'text-amber-600' : 'text-emerald-600'}`}>
                {count}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Requests */}
      <div className="card min-w-0">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-serif font-semibold text-ink">
            Recent Expense Requests
          </h2>
          <Link to="/requests" className="text-sm font-medium text-brand hover:text-brand-dark flex items-center gap-1">
            View all <span aria-hidden="true">&rarr;</span>
          </Link>
        </div>
        
        {recentRequests?.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="table">
              <thead>
                <tr>
                  <th>Request ID</th>
                  <th>Payee</th>
                  <th>Category</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {recentRequests.map((req) => (
                  <tr key={req.id}>
                    <td>
                      <Link to={`/requests/${req.id}`} className="font-mono text-brand hover:underline">
                        {req.request_id}
                      </Link>
                    </td>
                    <td>
                      <div className="font-medium text-ink truncate max-w-[150px]" title={req.payee_name}>
                        {req.payee_name}
                      </div>
                    </td>
                    <td className="text-muted">{req.category_name}</td>
                    <td className="font-mono">{formatCurrency(req.total_amount_usd)}</td>
                    <td><StatusBadge status={req.status} /></td>
                    <td className="text-sm text-muted">{formatDate(req.created_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12 border-2 border-dashed border-line rounded-lg">
            <FileText size={48} className="mx-auto text-muted mb-4 opacity-50" />
            <p className="text-ink font-medium">No recent requests found.</p>
            <p className="text-muted text-sm mt-1">Start by creating a new expense request.</p>
          </div>
        )}
      </div>
    </div>
  );
}
