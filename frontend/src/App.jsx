import { Routes, Route, Navigate } from 'react-router-dom';
import { useEffect } from 'react';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import Layout from '@/components/Layout';
import LoginPage from '@/pages/LoginPage';
import SignupPage from '@/pages/SignupPage';
import SettingsPage from '@/pages/SettingsPage';
import Dashboard from '@/pages/Dashboard';
import RequestListPage from '@/pages/RequestListPage';
import RequestCreatePage from '@/pages/RequestCreatePage';
import RequestDetailPage from '@/pages/RequestDetailPage';
import MyTasksPage from '@/pages/MyTasksPage';
import ReconciliationPage from '@/pages/ReconciliationPage';
import IncomeReceiptsPage from '@/pages/IncomeReceiptsPage';
import ExceptionsPage from '@/pages/ExceptionsPage';

// Protected route wrapper
const ProtectedRoute = ({ children }) => {
  const { user, isAuthenticated, loading, logout } = useAuth();

  useEffect(() => {
    if (!loading && user?.role === 'Staff') {
      logout();
    }
  }, [loading, user, logout]);
  
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-brand mx-auto"></div>
          <p className="mt-4 text-muted">Loading...</p>
        </div>
      </div>
    );
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (user?.role === 'Staff') {
    return <Navigate to="/login" replace />;
  }
  
  return <Layout>{children}</Layout>;
};

function AppRoutes() {
  const { isAuthenticated } = useAuth();
  
  return (
    <Routes>
      <Route 
        path="/login" 
        element={isAuthenticated ? <Navigate to="/" replace /> : <LoginPage />} 
      />
      <Route 
        path="/signup" 
        element={isAuthenticated ? <Navigate to="/" replace /> : <SignupPage />} 
      />
      
      <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
      <Route path="/settings" element={<ProtectedRoute><SettingsPage /></ProtectedRoute>} />
      <Route path="/my-tasks" element={<ProtectedRoute><MyTasksPage /></ProtectedRoute>} />
      <Route path="/requests" element={<ProtectedRoute><RequestListPage /></ProtectedRoute>} />
      <Route path="/requests/new" element={<ProtectedRoute><RequestCreatePage /></ProtectedRoute>} />
      <Route path="/requests/:id" element={<ProtectedRoute><RequestDetailPage /></ProtectedRoute>} />
      <Route path="/reconciliations" element={<ProtectedRoute><ReconciliationPage /></ProtectedRoute>} />
      <Route path="/income-receipts" element={<ProtectedRoute><IncomeReceiptsPage /></ProtectedRoute>} />
      <Route path="/exceptions" element={<ProtectedRoute><ExceptionsPage /></ProtectedRoute>} />
      
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}

export default App;
