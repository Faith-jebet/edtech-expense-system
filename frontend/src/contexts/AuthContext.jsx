import React, { createContext, useContext, useState, useEffect } from 'react';
import { auth } from '@/lib/api';
import toast from 'react-hot-toast';

const AuthContext = createContext(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Load user from localStorage on mount
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      try {
        setUser(JSON.parse(storedUser));
      } catch (error) {
        localStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email, password) => {
    try {
      const response = await auth.login({ email, password });
      const { access_token, user: userData } = response.data;

      if (userData.role === 'Staff') {
        toast.error('Staff accounts do not have access to the finance workflow');
        return false;
      }
      
      localStorage.setItem('access_token', access_token);
      localStorage.setItem('user', JSON.stringify(userData));
      setUser(userData);
      
      toast.success(`Welcome back, ${userData.full_name || userData.first_name || userData.email}!`);
      return true;
    } catch (error) {
      const message = error.response?.data?.error || 'Login failed';
      toast.error(message);
      return false;
    }
  };

  const logout = async () => {
    try {
      await auth.logout();
    } catch (error) {
      // Logout anyway even if API call fails
      console.error('Logout error:', error);
    } finally {
      localStorage.removeItem('access_token');
      localStorage.removeItem('user');
      setUser(null);
      toast.success('Logged out successfully');
    }
  };

  const hasRole = (roles) => {
    if (!user) return false;
    if (Array.isArray(roles)) {
      return roles.includes(user.role);
    }
    return user.role === roles;
  };

  const canVerify = () => hasRole('Accountant');
  const canApprove = (amount) => {
    if (!user) return false;
    if (user.role === 'Director') return true;
    if (user.role === 'Managing Director') return true;
    return false;
  };
  const canPay = () => hasRole('Paying Officer');
  const canPost = () => hasRole('Accountant');
  const isAdmin = () => hasRole('Admin');

  const value = {
    user,
    loading,
    login,
    logout,
    hasRole,
    canVerify,
    canApprove,
    canPay,
    canPost,
    isAdmin,
    isAuthenticated: !!user,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
