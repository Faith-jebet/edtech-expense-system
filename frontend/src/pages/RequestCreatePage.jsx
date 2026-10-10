import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { projects, categories, expenseRequests } from '@/lib/api';
import toast from 'react-hot-toast';
import { PlusCircle, Trash2, ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';

const itemSchema = z.object({
  description: z.string().min(1, 'Description is required'),
  quantity: z.string().min(1, 'Quantity is required'),
  unit_cost: z.string().min(1, 'Unit cost is required'),
});

const requestSchema = z.object({
  project_id: z.string().min(1, 'Project is required').or(z.literal('new')),
  new_project_name: z.string().optional(),
  category_id: z.string().min(1, 'Category is required'),
  priority: z.enum(['Normal', 'Urgent']),
  payee_name: z.string().min(1, 'Payee name is required'),
  payee_details: z.string().optional(),
  currency: z.enum(['USD', 'KES', 'Other']),
  currency_other: z.string().optional(),
  business_justification: z.string().min(10, 'Please provide detailed justification (min 10 characters)'),
  payment_method: z.enum(['Bank Transfer', 'Mobile Money', 'Cash', 'Other']),
  budget_status: z.enum(['Within Budget', 'Outside Budget-Exception']),
  expected_payment_date: z.string().optional(),
  is_advance: z.boolean(),
  advance_retirement_deadline: z.string().optional(),
  items: z.array(itemSchema).min(1, 'At least one item is required'),
}).refine(data => data.project_id !== 'new' || (data.project_id === 'new' && data.new_project_name?.trim()), {
  message: "New project name is required",
  path: ["new_project_name"]
});

export default function RequestCreatePage() {
  const navigate = useNavigate();
  const [submitDraft, setSubmitDraft] = useState(false);
  
  const { data: projectsData } = useQuery({
    queryKey: ['projects'],
    queryFn: async () => {
      const response = await projects.list();
      return response.data.projects;
    },
  });
  
  const { data: categoriesData } = useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const response = await categories.list();
      return response.data.categories;
    },
  });
  
  const {
    register,
    control,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm({
    resolver: zodResolver(requestSchema),
    defaultValues: {
      priority: 'Normal',
      currency: 'USD',
      payment_method: 'Bank Transfer',
      budget_status: 'Within Budget',
      is_advance: false,
      items: [{ description: '', quantity: '1', unit_cost: '' }],
    },
  });
  
  const { fields, append, remove } = useFieldArray({
    control,
    name: 'items',
  });
  
  const watchCurrency = watch('currency');
  const watchProject = watch('project_id');
  const watchIsAdvance = watch('is_advance');
  const watchItems = watch('items');
  
  // Calculate total
  const calculateTotal = () => {
    return watchItems.reduce((sum, item) => {
      const qty = parseFloat(item.quantity) || 0;
      const cost = parseFloat(item.unit_cost) || 0;
      return sum + (qty * cost);
    }, 0);
  };
  
  const createMutation = useMutation({
    mutationFn: async (data) => {
      const response = await expenseRequests.create(data);
      return response.data;
    },
    onSuccess: async (data) => {
      toast.success('Request created successfully');
      
      if (submitDraft) {
        // Submit immediately
        try {
          await expenseRequests.submit(data.id);
          toast.success('Request submitted for verification');
        } catch (error) {
          toast.error('Request created but submission failed');
        }
      }
      
      navigate(`/requests/${data.id}`);
    },
    onError: (error) => {
      const message = error.response?.data?.error || 'Failed to create request';
      toast.error(message);
    },
  });
  
  const onSubmit = (data) => {
    // Convert string IDs to integers
    const payload = {
      ...data,
      project_id: data.project_id === 'new' ? null : parseInt(data.project_id),
      category_id: parseInt(data.category_id),
    };
    
    createMutation.mutate(payload);
  };
  
  return (
    <div>
      {/* Header */}
      <div className="mb-6">
        <Link to="/requests" className="inline-flex items-center gap-2 text-brand hover:text-brand-dark mb-4">
          <ArrowLeft size={18} />
          Back to Requests
        </Link>
        <h1 className="text-3xl font-serif font-semibold text-brand">
          New Expense Request
        </h1>
        <p className="text-muted mt-1">
          Complete the form below to create a new expense request
        </p>
      </div>
      
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Request Header */}
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">Request Details</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label htmlFor="project_id" className="label">
                Project / Cost Centre <span className="text-danger">*</span>
              </label>
              <select {...register('project_id')} id="project_id" className="input">
                <option value="">Select project...</option>
                {projectsData?.map((project) => (
                  <option key={project.id} value={project.id}>
                    {project.code} - {project.name}
                  </option>
                ))}
              </select>
              {errors.project_id && (
                <p className="error-message">{errors.project_id.message}</p>
              )}
            </div>
            
            <div>
              <label htmlFor="category_id" className="label">
                Expense Category <span className="text-danger">*</span>
              </label>
              <select {...register('category_id')} id="category_id" className="input">
                <option value="">Select category...</option>
                {categoriesData?.map((category) => (
                  <option key={category.id} value={category.id}>
                    {category.name}
                  </option>
                ))}
              </select>
              {errors.category_id && (
                <p className="error-message">{errors.category_id.message}</p>
              )}
            </div>
            
            <div>
              <label htmlFor="priority" className="label">
                Priority <span className="text-danger">*</span>
              </label>
              <select {...register('priority')} id="priority" className="input">
                <option value="Normal">Normal</option>
                <option value="Urgent">Urgent</option>
              </select>
            </div>
            
            <div>
              <label htmlFor="budget_status" className="label">
                Budget Status <span className="text-danger">*</span>
              </label>
              <select {...register('budget_status')} id="budget_status" className="input">
                <option value="Within Budget">Within Budget</option>
                <option value="Outside Budget-Exception">Outside Budget - Exception</option>
              </select>
            </div>
          </div>
        </div>
        
        {/* Payee Information */}
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">Payee Information</h2>
          
          <div className="space-y-4">
            <div>
              <label htmlFor="payee_name" className="label">
                Payee / Supplier Name <span className="text-danger">*</span>
              </label>
              <input
                {...register('payee_name')}
                type="text"
                id="payee_name"
                className="input"
                placeholder="e.g., ABC Suppliers Ltd"
              />
              {errors.payee_name && (
                <p className="error-message">{errors.payee_name.message}</p>
              )}
            </div>
            
            <div>
              <label htmlFor="payee_details" className="label">
                Payee Details (Bank Account, Mobile Number, etc.)
              </label>
              <textarea
                {...register('payee_details')}
                id="payee_details"
                rows={2}
                className="input"
                placeholder="e.g., Bank: KCB, Account: 1234567890"
              />
            </div>
          </div>
        </div>
        
        {/* Currency and Payment */}
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">Currency & Payment Method</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label htmlFor="currency" className="label">
                Currency <span className="text-danger">*</span>
              </label>
              <select {...register('currency')} id="currency" className="input">
                <option value="USD">USD</option>
                <option value="KES">KES</option>
                <option value="Other">Other</option>
              </select>
            </div>
            
            {watchCurrency === 'Other' && (
              <div>
                <label htmlFor="currency_other" className="label">
                  Specify Currency
                </label>
                <input
                  {...register('currency_other')}
                  type="text"
                  id="currency_other"
                  className="input"
                  placeholder="e.g., EUR, GBP"
                />
              </div>
            )}
            
            <div>
              <label htmlFor="payment_method" className="label">
                Payment Method <span className="text-danger">*</span>
              </label>
              <select {...register('payment_method')} id="payment_method" className="input">
                <option value="Bank Transfer">Bank Transfer</option>
                <option value="Mobile Money">Mobile Money</option>
                <option value="Cash">Cash</option>
                <option value="Other">Other</option>
              </select>
            </div>
            
            <div>
              <label htmlFor="expected_payment_date" className="label">
                Expected Payment Date
              </label>
              <input
                {...register('expected_payment_date')}
                type="date"
                id="expected_payment_date"
                className="input"
              />
            </div>
          </div>
        </div>
        
        {/* Line Items */}
        <div className="card">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-serif font-semibold">Line Items</h2>
            <button
              type="button"
              onClick={() => append({ description: '', quantity: '1', unit_cost: '' })}
              className="btn-secondary flex items-center gap-2 text-sm"
            >
              <PlusCircle size={16} />
              Add Item
            </button>
          </div>
          
          <div className="space-y-4">
            {fields.map((field, index) => (
              <div key={field.id} className="border border-line rounded-lg p-4">
                <div className="flex justify-between items-start mb-3">
                  <span className="text-sm font-medium text-muted">Item {index + 1}</span>
                  {fields.length > 1 && (
                    <button
                      type="button"
                      onClick={() => remove(index)}
                      className="text-danger hover:text-danger/80"
                      aria-label="Remove item"
                    >
                      <Trash2 size={18} />
                    </button>
                  )}
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-12 gap-3">
                  <div className="md:col-span-6">
                    <input
                      {...register(`items.${index}.description`)}
                      type="text"
                      className="input"
                      placeholder="Description / Purpose"
                    />
                    {errors.items?.[index]?.description && (
                      <p className="error-message text-xs">
                        {errors.items[index].description.message}
                      </p>
                    )}
                  </div>
                  
                  <div className="md:col-span-2">
                    <input
                      {...register(`items.${index}.quantity`)}
                      type="number"
                      step="0.01"
                      className="input"
                      placeholder="Qty"
                    />
                  </div>
                  
                  <div className="md:col-span-2">
                    <input
                      {...register(`items.${index}.unit_cost`)}
                      type="number"
                      step="0.01"
                      className="input"
                      placeholder="Unit Cost"
                    />
                  </div>
                  
                  <div className="md:col-span-2">
                    <input
                      type="text"
                      className="input bg-gray-50"
                      value={(
                        (parseFloat(watchItems[index]?.quantity) || 0) *
                        (parseFloat(watchItems[index]?.unit_cost) || 0)
                      ).toFixed(2)}
                      disabled
                      placeholder="Amount"
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
          
          {errors.items && (
            <p className="error-message mt-2">
              {errors.items.message || 'Please check all items'}
            </p>
          )}
          
          {/* Total */}
          <div className="mt-4 pt-4 border-t border-line">
            <div className="flex justify-between items-center">
              <span className="font-semibold text-brand">Total Amount:</span>
              <span className="text-2xl font-semibold text-ink">
                {watchCurrency} {calculateTotal().toFixed(2)}
              </span>
            </div>
          </div>
        </div>
        
        {/* Business Justification */}
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">Business Justification</h2>
          
          <div>
            <label htmlFor="business_justification" className="label">
              Explain the business need for this expense <span className="text-danger">*</span>
            </label>
            <textarea
              {...register('business_justification')}
              id="business_justification"
              rows={4}
              className="input"
              placeholder="Provide detailed justification for this expense..."
            />
            {errors.business_justification && (
              <p className="error-message">{errors.business_justification.message}</p>
            )}
          </div>
        </div>
        
        {/* Advance Options */}
        <div className="card">
          <h2 className="text-xl font-serif font-semibold mb-4">Advance Options</h2>
          
          <div className="space-y-4">
            <div className="flex items-center">
              <input
                {...register('is_advance')}
                type="checkbox"
                id="is_advance"
                className="h-4 w-4 text-brand focus:ring-brand border-line rounded"
              />
              <label htmlFor="is_advance" className="ml-2 text-sm text-ink">
                This is an advance payment
              </label>
            </div>
            
            {watchIsAdvance && (
              <div>
                <label htmlFor="advance_retirement_deadline" className="label">
                  Advance Retirement Deadline
                </label>
                <input
                  {...register('advance_retirement_deadline')}
                  type="date"
                  id="advance_retirement_deadline"
                  className="input"
                />
                <p className="text-xs text-muted mt-1">
                  Default is 14 days from payment date
                </p>
              </div>
            )}
          </div>
        </div>
        
        {/* Actions */}
        <div className="flex flex-col sm:flex-row gap-3">
          <button
            type="submit"
            disabled={createMutation.isPending}
            className="btn-primary flex-1 flex items-center justify-center gap-2"
            onClick={() => setSubmitDraft(false)}
          >
            {createMutation.isPending ? 'Saving...' : 'Save as Draft'}
          </button>
          
          <button
            type="submit"
            disabled={createMutation.isPending}
            className="btn-accent flex-1 flex items-center justify-center gap-2"
            onClick={() => setSubmitDraft(true)}
          >
            {createMutation.isPending ? 'Submitting...' : 'Save and Submit'}
          </button>
          
          <Link to="/requests" className="btn-outline flex-1 text-center">
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
