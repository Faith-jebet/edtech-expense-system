import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Users, FolderGit2, Activity, ShieldCheck, Settings, Server, Database, Key } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

export default function AdminDashboard() {
  const { user } = useAuth();
  
  return (
    <div className="space-y-8 animate-fade-in">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 md:p-8 rounded-2xl shadow-sm border border-line">
        <div>
          <h1 className="text-3xl font-serif font-bold text-ink mb-2">System Administrator</h1>
          <p className="text-muted text-sm max-w-2xl">
            Welcome back, {user?.full_name}. Monitor platform health, manage user access, and configure system-wide financial controls.
          </p>
        </div>
        <div className="flex shrink-0">
          <Link to="/settings" className="btn-primary flex items-center gap-2 shadow-md">
            <Settings size={18} />
            System Configuration
          </Link>
        </div>
      </div>
      
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="card p-6 border-l-4 border-l-brand flex items-start gap-4">
          <div className="p-3 bg-brand-light text-brand rounded-xl">
            <Users size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-muted mb-1">Active Accounts</p>
            <p className="text-2xl font-bold text-ink">8</p>
          </div>
        </div>
        
        <div className="card p-6 border-l-4 border-l-emerald-500 flex items-start gap-4">
          <div className="p-3 bg-emerald-100 text-emerald-600 rounded-xl">
            <FolderGit2 size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-muted mb-1">Active Projects</p>
            <p className="text-2xl font-bold text-ink">3</p>
          </div>
        </div>

        <div className="card p-6 border-l-4 border-l-amber-500 flex items-start gap-4">
          <div className="p-3 bg-amber-100 text-amber-600 rounded-xl">
            <ShieldCheck size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-muted mb-1">Security Policies</p>
            <p className="text-2xl font-bold text-ink">Strict</p>
          </div>
        </div>

        <div className="card p-6 border-l-4 border-l-blue-500 flex items-start gap-4">
          <div className="p-3 bg-blue-100 text-blue-600 rounded-xl">
            <Activity size={24} />
          </div>
          <div>
            <p className="text-sm font-medium text-muted mb-1">System Status</p>
            <p className="text-2xl font-bold text-ink">Healthy</p>
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="card border border-line">
          <h2 className="text-lg font-bold text-ink mb-6 flex items-center gap-2">
            <Server size={20} className="text-muted" /> Server Resources
          </h2>
          <div className="space-y-6">
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="font-medium text-gray-700">CPU Usage</span>
                <span className="text-muted">12%</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-2">
                <div className="bg-emerald-500 h-2 rounded-full" style={{ width: '12%' }}></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="font-medium text-gray-700">Memory Allocation</span>
                <span className="text-muted">1.2 GB / 4.0 GB</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-2">
                <div className="bg-brand h-2 rounded-full" style={{ width: '30%' }}></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2">
                <span className="font-medium text-gray-700">Storage Capacity</span>
                <span className="text-muted">45 GB / 100 GB</span>
              </div>
              <div className="w-full bg-gray-100 rounded-full h-2">
                <div className="bg-amber-500 h-2 rounded-full" style={{ width: '45%' }}></div>
              </div>
            </div>
          </div>
        </div>
        
        <div className="card border border-line">
          <h2 className="text-lg font-bold text-ink mb-6 flex items-center gap-2">
            <Database size={20} className="text-muted" /> Recent Audit Logs
          </h2>
          <div className="space-y-4">
            {[
              { action: 'User Created', target: 'John Doe (Accountant)', time: '2 hours ago' },
              { action: 'Threshold Updated', target: 'MD Approval Limit', time: '5 hours ago' },
              { action: 'Database Backed Up', target: 'Auto-schedule', time: '1 day ago' },
              { action: 'Role Modified', target: 'Jane Smith', time: '2 days ago' },
            ].map((log, i) => (
              <div key={i} className="flex justify-between items-center p-3 hover:bg-gray-50 rounded-lg transition-colors border border-transparent hover:border-gray-100">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-brand rounded-full"></div>
                  <div>
                    <p className="text-sm font-medium text-ink">{log.action}</p>
                    <p className="text-xs text-muted">{log.target}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-400 font-mono">{log.time}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
