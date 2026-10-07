# Quick Start Guide - Milestone EdTech Expense Control

Get the system running in 10 minutes!

---

## 📋 Prerequisites Checklist

Before starting, make sure you have:

- [ ] **Python 3.12+** installed (`python --version`)
- [ ] **Node.js 18+** installed (`node --version`)
- [ ] **MySQL Server** running (XAMPP, WAMP, or standalone MySQL)
- [ ] **phpMyAdmin** accessible (usually `http://localhost/phpmyadmin`)

---

## 🚀 Quick Setup (3 Steps)

### Step 1: Set Up Database (5 minutes)

1. **Open phpMyAdmin**: `http://localhost/phpmyadmin`

2. **Create Database**:
   - Click "Databases" tab
   - Name: `milestone_expense_db`
   - Collation: `utf8mb4_general_ci`
   - Click "Create"

3. **Create User**:
   - Click "User accounts" → "Add user account"
   - Username: `milestone_user`
   - Host: `localhost`
   - Password: `Milestone@2026!`
   - ✅ Check "Grant all privileges on database milestone_expense_db"
   - Click "Go"

4. **Import Schema**:
   - Click database name `milestone_expense_db`
   - Click "SQL" tab
   - Open file: `database_schema.sql`
   - Copy ALL contents
   - Paste into SQL box
   - Click "Go"
   - ✅ You should see "15 rows inserted" or similar success message

**✓ Database is ready!**

---

### Step 2: Start Backend (3 minutes)

Open PowerShell in project folder:

```powershell
# 1. Go to backend folder
cd backend

# 2. Create virtual environment
python -m venv venv

# 3. Activate it
.\venv\Scripts\Activate.ps1

# 4. Install packages
pip install -r requirements.txt

# 5. Create .env file
copy .env.example .env

# 6. Edit .env (paste this content)
notepad .env
```

**Paste this into .env:**
```bash
DB_USER=milestone_user
DB_PASSWORD=Milestone@2026!
DB_HOST=localhost
DB_PORT=3306
DB_NAME=milestone_expense_db

FLASK_APP=run.py
FLASK_ENV=development
SECRET_KEY=dev-secret-key-change-in-production
JWT_SECRET_KEY=dev-jwt-secret-change-in-production

UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=10485760
```

Save and close.

```powershell
# 7. Create demo users
python create_admin_user.py --demo

# 8. Start Flask server
python run.py
```

**✓ Backend running at http://localhost:5000**

---

### Step 3: Start Frontend (2 minutes)

Open NEW PowerShell window:

```powershell
# 1. Go to frontend folder
cd frontend

# 2. Install packages
npm install

# 3. Start React dev server
npm run dev
```

**✓ Frontend running at http://localhost:5173**

---

## 🎉 You're Done!

Open browser: **http://localhost:5173**

### Demo Login Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@milestone.com | admin123 |
| Operation Manager | operations@milestone.com | password123 |
| Accountant | accountant@milestone.com | accountant123 |
| Director | director@milestone.com | director123 |
| Paying Officer | payments@milestone.com | password123 |
| Managing Director | md@milestone.com | password123 |

---

## ✅ Test the System

1. **Login as Operation Manager** (operations@milestone.com / password123)
   - Click "New Request"
   - Fill out expense form
   - Submit

2. **Login as Accountant** (accountant@milestone.com / accountant123)
   - Go to "My Tasks"
   - You'll see the pending request
   - Verify and approve it

3. **Login as Paying Officer** (payments@milestone.com / password123)
   - Go to "My Tasks"
   - Process payment

4. **Login as Paying Officer** (payments@milestone.com / password123)
   - Upload proof of payment

5. **Login as Accountant** (accountant@milestone.com / accountant123)
   - Post to ledger
   - Close request

---

## 🔧 Troubleshooting

### Backend won't start

**Error: "No module named 'flask'"**
```powershell
# Make sure virtual environment is activated
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

**Error: "Access denied for user"**
- Check `.env` file has correct password
- Verify user exists in phpMyAdmin → User accounts

**Error: "Can't connect to MySQL server"**
- Start MySQL service (XAMPP Control Panel → Start MySQL)
- Check MySQL is running on port 3306

### Frontend won't start

**Error: "npm not found"**
- Install Node.js from nodejs.org

**Error: "Port 5173 already in use"**
```powershell
# Kill process using port
Get-Process -Id (Get-NetTCPConnection -LocalPort 5173).OwningProcess | Stop-Process
npm run dev
```

### Can't login

**Error: "Invalid credentials"**
- Make sure you ran: `python create_admin_user.py --demo`
- Check backend terminal for errors
- Verify users exist in phpMyAdmin → milestone_expense_db → users table

---

## 📚 Next Steps

1. Read `DATABASE_SETUP.md` for detailed database documentation
2. Read `HOW_FLASK_CONNECTS_TO_MYSQL.md` to understand the connection
3. Check `README.md` for complete feature list
4. Explore the system with different user roles

---

## 🆘 Still Having Issues?

Check these files for detailed help:
- `DATABASE_SETUP.md` - Complete database setup guide
- `HOW_FLASK_CONNECTS_TO_MYSQL.md` - Connection troubleshooting
- `README.md` - Full documentation

### Common Issues & Solutions

1. **"Table doesn't exist"**
   - Import `database_schema.sql` again in phpMyAdmin

2. **"Connection refused"**
   - Start MySQL server
   - Check port 3306 is not blocked

3. **"CORS error" in browser**
   - Backend must be running on port 5000
   - Frontend must be running on port 5173

4. **"Module not found" errors**
   - Delete `venv` folder and recreate it
   - Run `pip install -r requirements.txt` again

---

**🎯 Goal**: Get you up and running in 10 minutes!

If you've followed all steps and it's still not working, check the detailed guides listed above.
