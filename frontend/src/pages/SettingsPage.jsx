import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Settings, Users, Shield, Database, Bell, Lock, Mail, Globe, Save } from 'lucide-react';
import toast from 'react-hot-toast';

export default function SettingsPage() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState('users');

  if (user?.role !== 'Admin') {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-danger">
        <Lock size={64} className="mb-4 opacity-50" />
        <h2 className="text-2xl font-bold font-serif mb-2">Access Denied</h2>
        <p className="text-muted">You do not have permission to view System Settings.</p>
      </div>
    );
  }

  const handleSave = () => {
    toast.success('Settings saved successfully!');
  };

  return (
    <div className="max-w-6xl mx-auto animate-fade-in">
      <div className="mb-8">
        <h1 className="text-3xl font-serif font-semibold text-brand">System Configuration</h1>
        <p className="text-muted mt-2 text-lg">Manage platform settings, users, and security policies.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
        {/* Sidebar Tabs */}
        <div className="col-span-1 space-y-2">
          <button 
            onClick={() => setActiveTab('users')}
            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 font-medium transition-all ${
              activeTab === 'users' ? 'bg-brand text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-50 border border-transparent hover:border-gray-200'
            }`}
          >
            <Users size={18} /> User Management
          </button>
          
          <button 
            onClick={() => setActiveTab('thresholds')}
            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 font-medium transition-all ${
              activeTab === 'thresholds' ? 'bg-brand text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-50 border border-transparent hover:border-gray-200'
            }`}
          >
            <Shield size={18} /> Approval Thresholds
          </button>
          
          <button 
            onClick={() => setActiveTab('general')}
            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 font-medium transition-all ${
              activeTab === 'general' ? 'bg-brand text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-50 border border-transparent hover:border-gray-200'
            }`}
          >
            <Settings size={18} /> General Settings
          </button>
          
          <button 
            onClick={() => setActiveTab('notifications')}
            className={`w-full text-left px-4 py-3 rounded-xl flex items-center gap-3 font-medium transition-all ${
              activeTab === 'notifications' ? 'bg-brand text-white shadow-md' : 'bg-white text-gray-600 hover:bg-gray-50 border border-transparent hover:border-gray-200'
            }`}
          >
            <Bell size={18} /> Email & Alerts
          </button>
        </div>

        {/* Content Area */}
        <div className="col-span-1 md:col-span-3">
          {activeTab === 'users' && (
            <div className="card shadow-sm border border-line">
              <div className="flex justify-between items-center mb-6 border-b border-line pb-4">
                <h2 className="text-xl font-serif font-bold text-ink flex items-center gap-2">
                  <Users className="text-brand" /> User Management
                </h2>
                <button className="btn-accent text-sm py-1.5 px-4 rounded-lg">Add New User</button>
              </div>
              <div className="overflow-x-auto">
                <table className="table w-full text-sm">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="font-semibold text-gray-600 py-3">Name</th>
                      <th className="font-semibold text-gray-600 py-3">Email</th>
                      <th className="font-semibold text-gray-600 py-3">Role</th>
                      <th className="font-semibold text-gray-600 py-3">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {['John Doe', 'Jane Smith', 'David Clerk', 'Sarah Operations'].map((name, i) => (
                      <tr key={i} className="border-b border-line hover:bg-gray-50 transition-colors">
                        <td className="py-3 font-medium">{name}</td>
                        <td className="py-3 text-muted">{name.split(' ')[0].toLowerCase()}@milestone.com</td>
                        <td className="py-3">
                          <span className="bg-gray-100 text-gray-700 px-2 py-1 rounded text-xs font-medium border border-gray-200">
                            {['Admin', 'Accountant', 'Director', 'Operation Manager'][i]}
                          </span>
                        </td>
                        <td className="py-3">
                          <span className="text-emerald-600 flex items-center gap-1 text-xs font-medium">
                            <div className="w-2 h-2 rounded-full bg-emerald-500"></div> Active
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'thresholds' && (
            <div className="card shadow-sm border border-line">
              <div className="flex justify-between items-center mb-6 border-b border-line pb-4">
                <h2 className="text-xl font-serif font-bold text-ink flex items-center gap-2">
                  <Shield className="text-brand" /> Approval Limits (USD)
                </h2>
                <button onClick={handleSave} className="btn-primary text-sm py-1.5 px-4 rounded-lg flex items-center gap-2">
                  <Save size={16} /> Save Changes
                </button>
              </div>
              
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="label font-semibold text-gray-700">Accountant Verification Limit</label>
                    <p className="text-xs text-muted mb-2">Maximum amount before Senior Manager is required.</p>
                    <input type="number" defaultValue={100} className="input w-full" />
                  </div>
                  <div>
                    <label className="label font-semibold text-gray-700">Director Approval Limit</label>
                    <p className="text-xs text-muted mb-2">Maximum amount before Managing Director is required.</p>
                    <input type="number" defaultValue={500} className="input w-full" />
                  </div>
                </div>
                
                <div className="p-4 bg-blue-50 border border-blue-100 rounded-xl flex items-start gap-3 mt-6">
                  <Globe className="text-blue-500 shrink-0 mt-1" />
                  <div>
                    <h4 className="font-semibold text-blue-900 text-sm">Framework Compliance</h4>
                    <p className="text-sm text-blue-700 mt-1">
                      These values are strictly enforced by the backend routing logic. Changing these thresholds will immediately affect all newly submitted requests.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'general' && (
            <div className="card shadow-sm border border-line">
              <div className="flex justify-between items-center mb-6 border-b border-line pb-4">
                <h2 className="text-xl font-serif font-bold text-ink flex items-center gap-2">
                  <Settings className="text-brand" /> General Configuration
                </h2>
                <button onClick={handleSave} className="btn-primary text-sm py-1.5 px-4 rounded-lg flex items-center gap-2">
                  <Save size={16} /> Save Changes
                </button>
              </div>
              
              <div className="space-y-6">
                <div>
                  <label className="label">Company Name</label>
                  <input type="text" defaultValue="Milestone EdTech Solutions Ltd" className="input w-full md:w-2/3" />
                </div>
                <div>
                  <label className="label">Default Base Currency</label>
                  <select className="input w-full md:w-1/3">
                    <option value="USD">USD - US Dollar</option>
                    <option value="KES">KES - Kenyan Shilling</option>
                  </select>
                </div>
                <div>
                  <label className="label">Timezone</label>
                  <select className="input w-full md:w-2/3">
                    <option value="UTC">UTC (Universal Coordinated Time)</option>
                    <option value="Africa/Nairobi">Africa/Nairobi (EAT)</option>
                  </select>
                </div>
              </div>
            </div>
          )}

          {activeTab === 'notifications' && (
            <div className="card shadow-sm border border-line text-center py-16">
              <Mail size={48} className="mx-auto text-muted mb-4 opacity-30" />
              <h3 className="text-xl font-serif font-bold text-ink mb-2">SMTP Configuration</h3>
              <p className="text-muted max-w-md mx-auto">
                Email servers are currently mocked in the development environment. Setup your production SMTP credentials in the backend .env file.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
