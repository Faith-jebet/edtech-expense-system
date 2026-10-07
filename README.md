# Milestone EdTech - Expense & Payment Control System

Production-ready expense and payment control system implementing the complete "Transparent Finance & Expense Control Framework" with workflow automation, separation of duties, audit trails, and reconciliation.

## Features

- **Complete Workflow Automation**: 7-stage control process (Request, Review, Approval, Payment, Evidence, Record, Reconciliation)
- **Separation of Duties**: Operation Managers request, Accountants verify/reconcile/post, authorized approvers approve, and Paying Officers execute payments
- **Role-Based Access Control**: 6 roles (Operation Manager, Accountant, Director, Managing Director, Paying Officer, Admin)
- **Approval Routing by Amount**: Automatic routing based on USD value (≤$100, $101-$500, >$500)
- **Currency Support**: USD, KES, and custom currencies with exchange rate snapshots
- **Split Purchase Detection**: Flags multiple requests to same payee/project crossing approval thresholds
- **Unique Request IDs**: ME-EXP-YYYY-#### format with concurrency-safe generation
- **Immutable Audit Log**: All changes tracked with MySQL triggers preventing UPDATE/DELETE
- **Advance Tracking**: Automated reminders for overdue advance retirements
- **Mobile-Responsive UI**: WCAG AA compliant design with 60-30-10 color system

## Tech Stack

**Backend:**
- Python 3.12 + Flask 3
- MySQL 8 with InnoDB
- Flask-JWT-Extended (access + refresh tokens)
- Marshmallow for schemas
- APScheduler for reminders
- ReportLab for PDFs

**Frontend:**
- React 18 + Vite
- Tailwind CSS with custom design system
- TanStack Query for data fetching
- React Hook Form + Zod validation
- Recharts for visualizations

## Database Setup (phpMyAdmin)

### External MySQL Setup (Production Approach)

This system uses an **external MySQL database** managed via phpMyAdmin. Database schema is created manually (not using migrations).

**📖 Complete Setup Guide**: See `DATABASE_SETUP.md` and `QUICKSTART.md`

**Quick Steps**:

1. **Create Database in phpMyAdmin**:
   - Database name: `milestone_expense_db`
   - Collation: `utf8mb4_general_ci`

2. **Create User**:
   - Username: `milestone_user`
   - Password: Your choice (update in `.env`)
   - Grant all privileges on `milestone_expense_db`

3. **Import Schema**:
   - Open `database_schema.sql`
   - Copy and paste into phpMyAdmin SQL tab
   - Execute to create 15 tables + triggers

4. **Configure Backend**:
```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Create .env file
copy .env.example .env
# Edit .env with your database credentials
```

5. **Create Users**:
```powershell
python create_admin_user.py --demo
```

6. **Start Backend**:
```powershell
python run.py
```

**📄 Files for Database Setup**:
- `database_schema.sql` - Complete SQL schema for phpMyAdmin
- `DATABASE_SETUP.md` - Detailed setup instructions
- `HOW_FLASK_CONNECTS_TO_MYSQL.md` - Connection explanation
- `QUICKSTART.md` - 10-minute setup guide

**Note**: This system does NOT use Flask-Migrate. Database is managed externally via phpMyAdmin.

### Frontend Setup

**PowerShell or Git Bash:**
```bash
cd frontend

# Install dependencies
npm install

# Run development server
npm run dev
```

Frontend will run on http://localhost:5173

### Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Operation Manager | operations@milestone.com | password123 |
| Accountant | accountant@milestone.com | accountant123 |
| Director | director@milestone.com | director123 |
| Managing Director | md@milestone.com | password123 |
| Paying Officer | payments@milestone.com | password123 |
| Admin | admin@milestonetech.com | admin123 |

## Testing

### Backend Tests

```bash
cd backend
pytest
pytest --cov=app --cov-report=html
```

### Frontend Tests

```bash
cd frontend
npm run test
npm run test:coverage
```

## Production Deployment (Linux)

### Prerequisites

- Ubuntu 20.04+ or CentOS 8+
- Python 3.12+
- MySQL 8
- Nginx
- Certbot (Let's Encrypt)

### 1. System Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y python3.12 python3.12-venv python3-pip nginx mysql-server git

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Secure MySQL
sudo mysql_secure_installation
```

### 2. Database Setup

```bash
sudo mysql -u root -p

CREATE DATABASE edtech_expense_control CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'expense_app_user'@'localhost' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT SELECT, INSERT, UPDATE, DELETE ON edtech_expense_control.* TO 'expense_app_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Application Setup

```bash
# Create app user
sudo useradd -m -s /bin/bash edtech
sudo su - edtech

# Clone repository
git clone https://github.com/yourusername/edtech-expense-control.git
cd edtech-expense-control

# Backend setup
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt gunicorn

# Configure environment
cp .env.example .env
nano .env
# Set production values:
# FLASK_ENV=production
# SECRET_KEY=<generate with: python -c "import secrets; print(secrets.token_hex(32))">
# JWT_SECRET_KEY=<generate another>
# DB credentials, email config, etc.

# Run migrations
flask db upgrade

# Frontend setup
cd ../frontend
npm install
npm run build
```

### 4. Gunicorn + Systemd

Create `/etc/systemd/system/edtech-expense.service`:

```ini
[Unit]
Description=EdTech Expense Control Backend
After=network.target mysql.service

[Service]
User=edtech
Group=edtech
WorkingDirectory=/home/edtech/edtech-expense-control/backend
Environment="PATH=/home/edtech/edtech-expense-control/backend/.venv/bin"
ExecStart=/home/edtech/edtech-expense-control/backend/.venv/bin/gunicorn \
    --workers 4 \
    --bind 127.0.0.1:5000 \
    --timeout 120 \
    --access-logfile /var/log/edtech-expense/access.log \
    --error-logfile /var/log/edtech-expense/error.log \
    run:app

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Create log directory:
```bash
sudo mkdir -p /var/log/edtech-expense
sudo chown edtech:edtech /var/log/edtech-expense
```

Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable edtech-expense
sudo systemctl start edtech-expense
sudo systemctl status edtech-expense
```

### 5. Nginx Configuration

Create `/etc/nginx/sites-available/edtech-expense`:

```nginx
server {
    listen 80;
    server_name expense.milestonetech.com;
    
    client_max_body_size 10M;
    
    # Frontend (built React app)
    location / {
        root /home/edtech/edtech-expense-control/frontend/dist;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 120s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }
    
    # File uploads (authenticated via backend)
    location /api/v1/expense-requests/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # Allow larger uploads
        client_max_body_size 10M;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/edtech-expense /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 6. HTTPS with Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d expense.milestonetech.com
# Follow prompts, select redirect HTTP to HTTPS

# Auto-renewal (certbot installs a systemd timer)
sudo systemctl status certbot.timer
```

### 7. Automated Backups

Create `/home/edtech/backup-edtech.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/edtech/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="edtech_expense_control"

mkdir -p $BACKUP_DIR

# Database backup
mysqldump -u expense_app_user -p'PASSWORD' $DB_NAME | gzip > "$BACKUP_DIR/db_$DATE.sql.gz"

# Media files backup
tar -czf "$BACKUP_DIR/media_$DATE.tar.gz" /home/edtech/edtech-expense-control/backend/uploads/

# Keep only last 30 days
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
```

Add to crontab:
```bash
chmod +x /home/edtech/backup-edtech.sh
crontab -e
# Add line:
0 2 * * * /home/edtech/backup-edtech.sh >> /home/edtech/backup.log 2>&1
```

## Security Checklist

- [ ] Change all default passwords
- [ ] Generate new SECRET_KEY and JWT_SECRET_KEY
- [ ] Configure firewall (ufw allow 80/tcp, 443/tcp, 22/tcp)
- [ ] Enable MySQL audit logging
- [ ] Set up fail2ban for SSH
- [ ] Configure regular security updates
- [ ] Enable 2FA for admin and approver accounts
- [ ] Restrict database user permissions (no UPDATE/DELETE on audit_log)
- [ ] Configure email notifications for failed login attempts
- [ ] Set up monitoring (e.g., Prometheus, Grafana)
- [ ] Regular backup testing and verification

## Assumptions & Open Questions for Management

1. **Approval Limits**: Current defaults are USD 100 / 500. Confirm these match your delegation policy.

2. **Payment Tolerance**: Default 2% variance between approved and actual amount. Adjust if needed.

3. **SLA Periods**:
   - Approval: 2 working days
   - Payment: 3 working days
   - Receipt upload: 5 working days
   - Advance retirement: 14 days
   
4. **MD Request Approval**: When MD submits a request, it escalates to a Director. Who is the designated approver?

5. **Brand Colors**: The system uses Deep Navy (#1F4E79) and Amber (#D98E04). Provide official brand colors if different.

6. **Email Server**: Configure production SMTP credentials in .env (currently using Gmail defaults).

7. **Multi-currency**: Beyond USD and KES, which other currencies should be pre-configured?

8. **Document Retention**: How long should closed requests and audit logs be retained?

9. **User Roles**: Should we add regional approvers or department-specific roles?

10. **Integration**: Any existing accounting software (e.g., QuickBooks, Xero) to integrate with?

## Support

For issues or questions, contact: support@milestonetech.com

## License

Proprietary - Milestone EdTech Solutions Ltd © 2026
