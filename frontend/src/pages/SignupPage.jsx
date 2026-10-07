import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { UserPlus, Eye, EyeOff } from 'lucide-react';
import toast from 'react-hot-toast';
import axios from 'axios';

const signupSchema = z.object({
  full_name: z.string().min(2, 'Full name is required'),
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  role: z.string().min(1, 'Role is required'),
});

const ROLES = [
  'Operation Manager',
  'Accountant',
  'Director',
  'Managing Director',
  'Paying Officer',
  'Staff'
];

const API_URL = import.meta.env.VITE_API_URL || '/api/v1';

export default function SignupPage() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(signupSchema),
  });

  const onSubmit = async (data) => {
    setIsLoading(true);
    try {
      await axios.post(`${API_URL}/auth/signup`, data);
      toast.success('Registration successful! Please log in.');
      navigate('/login');
    } catch (error) {
      toast.error(error.response?.data?.error || 'Registration failed');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-[100dvh] grid lg:grid-cols-2 bg-canvas">
      {/* Brand panel (large screens only) */}
      <aside className="hidden lg:flex flex-col justify-between bg-brand text-white p-12 xl:p-16">
        <p className="text-sm uppercase tracking-widest text-white/70">
          Milestone EdTech Solutions Ltd
        </p>

        <div>
          <h1 className="font-serif text-4xl xl:text-5xl font-semibold leading-tight">
            Expense &amp; Payment Control System
          </h1>
          <p className="mt-5 max-w-md text-lg text-white/80">
            Every amount received or spent is traceable, authorized, supported
            by evidence, recorded and reconciled.
          </p>
        </div>

        <p className="text-sm text-white/60">
          Internal Control • Approval • Payment • Documentation • Reconciliation
        </p>
      </aside>

      {/* Form panel */}
      <main className="flex items-center justify-center px-4 py-8 sm:px-8 sm:py-12">
        <div className="w-full max-w-sm sm:max-w-md">
          {/* Title for phones and tablets, where the brand panel is hidden */}
          <div className="lg:hidden text-center mb-6 sm:mb-8">
            <p className="text-2xl sm:text-3xl font-serif font-semibold text-brand">
              Milestone EdTech
            </p>
            <p className="mt-1 text-sm sm:text-base text-muted">
              Expense &amp; Payment Control System
            </p>
          </div>

          <div className="card">
            <h2 className="text-2xl font-serif font-semibold text-brand">
              Create Account
            </h2>
            <p className="mt-1 mb-6 text-sm text-muted">
              Register for a new company account.
            </p>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-5" noValidate>
              <div>
                <label htmlFor="full_name" className="label">
                  Full Name
                </label>
                <input
                  {...register('full_name')}
                  type="text"
                  id="full_name"
                  className="input"
                  placeholder="John Doe"
                  aria-invalid={errors.full_name ? 'true' : 'false'}
                />
                {errors.full_name && (
                  <p className="error-message">{errors.full_name.message}</p>
                )}
              </div>

              <div>
                <label htmlFor="email" className="label">
                  Email address
                </label>
                <input
                  {...register('email')}
                  type="email"
                  id="email"
                  className="input"
                  placeholder="name@company.com"
                  autoComplete="email"
                  aria-invalid={errors.email ? 'true' : 'false'}
                />
                {errors.email && (
                  <p className="error-message">{errors.email.message}</p>
                )}
              </div>

              <div>
                <label htmlFor="role" className="label">
                  Select Role
                </label>
                <select
                  {...register('role')}
                  id="role"
                  className="input"
                  defaultValue=""
                  aria-invalid={errors.role ? 'true' : 'false'}
                >
                  <option value="" disabled>Select a role...</option>
                  {ROLES.map((role) => (
                    <option key={role} value={role}>
                      {role}
                    </option>
                  ))}
                </select>
                {errors.role && (
                  <p className="error-message">{errors.role.message}</p>
                )}
              </div>

              <div>
                <label htmlFor="password" className="label">
                  Password
                </label>
                <div className="relative">
                  <input
                    {...register('password')}
                    type={showPassword ? 'text' : 'password'}
                    id="password"
                    className="input pr-10"
                    placeholder="••••••••"
                    autoComplete="new-password"
                    aria-invalid={errors.password ? 'true' : 'false'}
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center text-muted hover:text-ink focus:outline-none"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
                {errors.password && (
                  <p className="error-message">{errors.password.message}</p>
                )}
              </div>

              <button
                type="submit"
                disabled={isLoading}
                className="btn-primary w-full min-h-[44px] flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                    Registering...
                  </>
                ) : (
                  <>
                    <UserPlus size={18} />
                    Sign up
                  </>
                )}
              </button>
            </form>
            
            <div className="mt-8 text-center text-sm">
              <span className="text-muted">Already have an account? </span>
              <Link to="/login" className="font-medium text-brand hover:text-brand-dark transition-colors">
                Sign in here
              </Link>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
