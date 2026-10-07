import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { 
  Home, 
  FileText, 
  CheckSquare, 
  LogOut, 
  Menu,
  X,
  DollarSign,
  RefreshCw,
  AlertTriangle
} from 'lucide-react';
import { useState } from 'react';

export default function Layout({ children }) {
  const { user, logout } = useAuth();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  const navigation = [
    { name: 'Dashboard', href: '/', icon: Home },
    { name: 'My Tasks', href: '/my-tasks', icon: CheckSquare },
    { name: 'All Requests', href: '/requests', icon: FileText },
    { name: 'Income Receipts', href: '/income-receipts', icon: DollarSign, roles: ['Accountant', 'Admin'] },
    { name: 'Reconciliations', href: '/reconciliations', icon: RefreshCw, roles: ['Accountant', 'Admin'] },
    { name: 'Exceptions', href: '/exceptions', icon: AlertTriangle, roles: ['Accountant', 'Director', 'Managing Director', 'Admin'] },
  ];
  
  const isActive = (path) => location.pathname === path;
  
  // Filter navigation based on user role
  const filteredNav = navigation.filter(item => 
    !item.roles || item.roles.includes(user?.role)
  );
  
  return (
    <div className="min-h-screen flex flex-col">
      {/* Top bar */}
      <header className="bg-brand text-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            {/* Logo and title */}
            <div className="flex items-center">
              <button
                className="md:hidden mr-2"
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                aria-label="Toggle menu"
              >
                {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
              <Link to="/" className="flex items-center">
                <h1 className="text-xl font-serif font-semibold text-white">
                  Milestone EdTech
                </h1>
              </Link>
            </div>
            
            {/* User info and logout */}
            <div className="flex items-center gap-4">
              <div className="hidden sm:block text-right">
                <p className="text-sm font-medium">{user?.full_name}</p>
                <p className="text-xs opacity-90">{user?.role}</p>
              </div>
              <button
                onClick={logout}
                className="flex items-center gap-2 px-3 py-2 rounded-md hover:bg-brand-dark transition-colors"
                aria-label="Logout"
              >
                <LogOut size={18} />
                <span className="hidden sm:inline">Logout</span>
              </button>
            </div>
          </div>
        </div>
      </header>
      
      {/* Navigation */}
      <nav className={`bg-white border-b border-line ${mobileMenuOpen ? 'block' : 'hidden md:block'}`}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col md:flex-row md:space-x-8">
            {filteredNav.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.href);
              return (
                <Link
                  key={item.name}
                  to={item.href}
                  className={`flex items-center gap-2 px-3 py-4 border-b-2 transition-colors ${
                    active
                      ? 'border-brand text-brand font-medium'
                      : 'border-transparent text-muted hover:text-ink hover:border-line'
                  }`}
                  onClick={() => setMobileMenuOpen(false)}
                >
                  <Icon size={18} />
                  <span>{item.name}</span>
                </Link>
              );
            })}
          </div>
        </div>
      </nav>
      
      {/* Main content */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
      
      {/* Footer */}
      <footer className="bg-white border-t border-line mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <p className="text-center text-sm text-muted">
            © 2026 Milestone EdTech Solutions Ltd. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
