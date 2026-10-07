import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { LogIn, Eye, EyeOff } from 'lucide-react';
import { Link } from 'react-router-dom';

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
});

// Where the Flask API lives. Set VITE_API_URL in .env if it is not served from /api/v1.
const API_URL = import.meta.env.VITE_API_URL || '/api/v1';

function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden="true">
      <path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9.1 3.5l6.8-6.8C35.8 2.4 30.3 0 24 0 14.6 0 6.5 5.4 2.6 13.2l7.9 6.1C12.4 13.6 17.7 9.5 24 9.5z"/>
      <path fill="#4285F4" d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.7c-.6 3-2.3 5.5-4.8 7.2l7.6 5.9c4.4-4.1 7-10.1 7-17.6z"/>
      <path fill="#FBBC05" d="M10.5 28.7A14.5 14.5 0 0 1 9.5 24c0-1.6.3-3.2.8-4.7l-7.9-6.1A24 24 0 0 0 0 24c0 3.9.9 7.5 2.6 10.8l7.9-6.1z"/>
      <path fill="#34A853" d="M24 48c6.5 0 11.9-2.1 15.9-5.8l-7.6-5.9c-2.1 1.4-4.9 2.3-8.3 2.3-6.3 0-11.6-4.1-13.5-9.8l-7.9 6.1C6.5 42.6 14.6 48 24 48z"/>
    </svg>
  );
}

export default function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data) => {
    setIsLoading(true);
    const success = await login(data.email, data.password);
    setIsLoading(false);

    if (success) {
      navigate('/');
    }
  };

  // Hands over to the backend, which redirects to Google and back to the app
  const handleGoogleSignIn = () => {
    window.location.href = `${API_URL}/auth/google`;
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
              Sign in
            </h2>
            <p className="mt-1 mb-6 text-sm text-muted">
              Use your company account to continue.
            </p>

            {/* Continue with Google */}
            <button
              type="button"
              onClick={handleGoogleSignIn}
              disabled={isLoading}
              className="w-full min-h-[44px] flex items-center justify-center gap-3 rounded-md border border-gray-300 bg-white px-4 py-2.5 text-sm sm:text-base font-medium text-gray-700 transition-colors hover:bg-gray-50 focus:outline-none focus-visible:ring-2 focus-visible:ring-brand disabled:opacity-60 disabled:cursor-not-allowed"
            >
              <GoogleIcon />
              Continue with Google
            </button>

            {/* Divider */}
            <div className="my-6 flex items-center gap-3" role="separator" aria-label="or">
              <div className="h-px flex-1 bg-gray-200"></div>
              <span className="text-xs uppercase tracking-wide text-muted">or</span>
              <div className="h-px flex-1 bg-gray-200"></div>
            </div>

            <form onSubmit={handleSubmit(onSubmit)} className="space-y-5" noValidate>
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
                  aria-describedby={errors.email ? 'email-error' : undefined}
                />
                {errors.email && (
                  <p id="email-error" role="alert" className="error-message">
                    {errors.email.message}
                  </p>
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
                    autoComplete="current-password"
                    aria-invalid={errors.password ? 'true' : 'false'}
                    aria-describedby={errors.password ? 'password-error' : undefined}
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
                  <p id="password-error" role="alert" className="error-message">
                    {errors.password.message}
                  </p>
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
                    Signing in...
                  </>
                ) : (
                  <>
                    <LogIn size={18} />
                    Sign in
                  </>
                )}
              </button>
            </form>
            
            <div className="mt-8 text-center text-sm">
              <span className="text-muted">Don't have an account? </span>
              <Link to="/signup" className="font-medium text-brand hover:text-brand-dark transition-colors">
                Sign up here
              </Link>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}