# How Flask Connects to External MySQL Database

This document explains **exactly** how the Flask backend connects to your external MySQL database set up in phpMyAdmin.

---

## The Simple Answer

Flask uses **SQLAlchemy** (a Python library) to connect to MySQL using a **connection string** that looks like this:

```
mysql+pymysql://username:password@host:port/database_name
```

---

## Step-by-Step Connection Flow

### 1. You Set Up MySQL in phpMyAdmin

```
┌──────────────────────────────┐
│       phpMyAdmin             │
│   (Web Interface)            │
│                              │
│  1. Create database:         │
│     milestone_expense_db     │
│                              │
│  2. Create user:             │
│     milestone_user           │
│     Password: Milestone@2026!│
│                              │
│  3. Import SQL schema        │
│     (15 tables + triggers)   │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│      MySQL Server            │
│      Running on:             │
│      localhost:3306          │
│                              │
│  Database: milestone_expense_db
│  Tables: users, projects,    │
│          expense_requests... │
└──────────────────────────────┘
```

### 2. You Configure Flask Backend

You create a `.env` file in the `backend/` folder:

```bash
# backend/.env
DB_USER=milestone_user
DB_PASSWORD=Milestone@2026!
DB_HOST=localhost
DB_PORT=3306
DB_NAME=milestone_expense_db
```

### 3. Flask Reads Configuration

The `backend/config.py` file reads your `.env` file:

```python
import os
from dotenv import load_dotenv

load_dotenv()  # Load variables from .env file

class Config:
    # Build connection string from environment variables
    SQLALCHEMY_DATABASE_URI = (
        f"mysql+pymysql://"
        f"{os.getenv('DB_USER')}:"           # milestone_user
        f"{os.getenv('DB_PASSWORD')}"        # Milestone@2026!
        f"@{os.getenv('DB_HOST')}:"          # localhost
        f"{os.getenv('DB_PORT')}/"           # 3306
        f"{os.getenv('DB_NAME')}"            # milestone_expense_db
        f"?charset=utf8mb4"
    )
    
    # Result: mysql+pymysql://milestone_user:Milestone@2026!@localhost:3306/milestone_expense_db?charset=utf8mb4
```

### 4. Flask Creates Database Connection

In `backend/app/__init__.py`:

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

# Create database object
db = SQLAlchemy()

def create_app():
    app = Flask(__name__)
    
    # Load configuration (includes database connection string)
    app.config.from_object('config.Config')
    
    # Initialize database connection
    # This connects to MySQL using the connection string
    db.init_app(app)
    
    return app
```

When `db.init_app(app)` runs, SQLAlchemy:
1. Reads the connection string from `app.config`
2. Opens a connection to MySQL at `localhost:3306`
3. Logs in with username `milestone_user` and password
4. Selects database `milestone_expense_db`
5. Ready to execute queries!

### 5. Your Models Map to Database Tables

Each Python model class maps to a table in your MySQL database:

```python
# backend/app/models/user.py
from app import db

class User(db.Model):
    __tablename__ = 'users'  # Maps to 'users' table in MySQL
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True)
    full_name = db.Column(db.String(100))
    # ... more columns
```

When you do:
```python
user = User.query.get(1)
```

SQLAlchemy translates this to SQL:
```sql
SELECT * FROM users WHERE id = 1;
```

And executes it on your MySQL database!

### 6. API Routes Use Models to Query Database

In `backend/app/api/v1/users.py`:

```python
@api_v1.route('/users', methods=['GET'])
def get_users():
    # This queries the 'users' table in your MySQL database
    users = User.query.all()
    
    return jsonify({
        'users': [{'id': u.id, 'name': u.full_name} for u in users]
    })
```

Flow:
```
HTTP Request → Flask Route → SQLAlchemy Model → MySQL Query → MySQL Database
                    ↓
HTTP Response ← Flask Route ← SQLAlchemy Model ← MySQL Result ← MySQL Database
```

---

## Complete Connection Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR COMPUTER                         │
│                                                          │
│  ┌─────────────────┐              ┌─────────────────┐  │
│  │   Web Browser   │              │  MySQL Server   │  │
│  │  phpMyAdmin     │─────────────▶│  Port: 3306     │  │
│  │                 │  Manage DB   │                 │  │
│  └─────────────────┘              │  Database:      │  │
│                                    │  milestone_...  │  │
│                                    │                 │  │
│  ┌─────────────────┐              │  Tables:        │  │
│  │                 │              │  - users        │  │
│  │  Flask Backend  │              │  - projects     │  │
│  │  (Python)       │              │  - expense_...  │  │
│  │                 │              │  - attachments  │  │
│  │  1. Reads       │              │  - approvals    │  │
│  │     .env file   │              │  ... 15 tables  │  │
│  │                 │              └────────▲────────┘  │
│  │  2. Builds      │                       │           │
│  │     connection  │                       │           │
│  │     string      │                       │           │
│  │                 │                       │           │
│  │  3. SQLAlchemy ──────────────────────────           │
│  │     connects    │  Connection String:               │
│  │     via         │  mysql+pymysql://                 │
│  │     pymysql     │  milestone_user:password@         │
│  │                 │  localhost:3306/                  │
│  │  4. Queries/    │  milestone_expense_db             │
│  │     Inserts     │                                   │
│  │     data        │                                   │
│  └─────────────────┘                                   │
│                                                         │
│  ┌─────────────────┐                                   │
│  │  React Frontend │                                   │
│  │  Port: 5173     │                                   │
│  │                 │                                   │
│  │  Calls Flask    │                                   │
│  │  API endpoints  │                                   │
│  └────────┬────────┘                                   │
│           │                                            │
│           ▼                                            │
│  ┌─────────────────┐                                   │
│  │  Flask API      │                                   │
│  │  Port: 5000     │                                   │
│  │                 │                                   │
│  │  Routes use     │                                   │
│  │  SQLAlchemy     │                                   │
│  │  models         │                                   │
│  └─────────────────┘                                   │
└─────────────────────────────────────────────────────────┘
```

---

## What Each Component Does

### phpMyAdmin
- **Role**: Web interface to manage MySQL
- **What you do**: Create database, import schema, view/edit data
- **Connection**: Direct connection to MySQL server

### MySQL Server
- **Role**: Stores all your data
- **Location**: Running on your computer (localhost:3306)
- **Contents**: 15 tables with all expense data
- **Access**: Anyone with valid credentials can connect

### Flask Backend
- **Role**: Business logic and API
- **Connection method**: SQLAlchemy with pymysql driver
- **Connection string**: Stored in `.env` file
- **What it does**: 
  - Receives HTTP requests from frontend
  - Queries MySQL database
  - Returns JSON responses

### React Frontend
- **Role**: User interface
- **Connection**: Makes HTTP requests to Flask API
- **Does NOT**: Connect directly to MySQL (only through Flask)

---

## Testing the Connection

### Method 1: Using Python Shell

```powershell
cd backend
python

>>> from app import create_app, db
>>> from app.models import User
>>> app = create_app()
>>> with app.app_context():
...     users = User.query.all()
...     print(f"Found {len(users)} users")
```

If this works, your connection is successful!

### Method 2: Using Flask Route

Start Flask:
```powershell
cd backend
python run.py
```

Visit in browser:
```
http://localhost:5000/api/v1/users
```

Should return JSON list of users.

### Method 3: Direct MySQL Connection Test

```python
import pymysql

connection = pymysql.connect(
    host='localhost',
    user='milestone_user',
    password='Milestone@2026!',
    database='milestone_expense_db'
)

cursor = connection.cursor()
cursor.execute("SELECT COUNT(*) FROM users")
result = cursor.fetchone()
print(f"Users table has {result[0]} rows")

connection.close()
```

---

## Common Questions

### Q: Do I need Flask-Migrate?
**A:** No! Since you're creating the database manually in phpMyAdmin, you don't need migrations. The models in Flask just need to match your table structure.

### Q: What if my table structure changes?
**A:** Update the table in phpMyAdmin (ALTER TABLE), then update the corresponding Python model to match.

### Q: Can I use both Flask-Migrate and phpMyAdmin?
**A:** Not recommended. Choose one approach:
- **phpMyAdmin**: Manual control, good for learning
- **Flask-Migrate**: Automatic migrations, better for teams

### Q: Where is the data actually stored?
**A:** In MySQL's data directory on your computer. Usually `C:\xampp\mysql\data\milestone_expense_db\` (if using XAMPP) or similar location.

### Q: Can multiple Flask instances connect to same database?
**A:** Yes! Multiple Flask processes can connect to the same MySQL database simultaneously.

---

## Troubleshooting

### Error: "No module named 'pymysql'"
**Solution:**
```powershell
pip install pymysql
```

### Error: "Access denied for user 'milestone_user'"
**Solution:**
- Check username/password in `.env` file
- Verify user exists in phpMyAdmin → User accounts
- Check user has privileges on the database

### Error: "Can't connect to MySQL server on 'localhost'"
**Solution:**
- Start MySQL service (XAMPP Control Panel → Start MySQL)
- Check MySQL is running on port 3306
- Try `127.0.0.1` instead of `localhost` in `.env`

### Error: "Unknown database 'milestone_expense_db'"
**Solution:**
- Create the database in phpMyAdmin first
- Check database name spelling in `.env`

---

## Summary

1. **phpMyAdmin** = Tool to manage MySQL (create database, import schema)
2. **MySQL Server** = Actual database storing data
3. **Flask config.py** = Builds connection string from `.env`
4. **SQLAlchemy** = Python library that connects to MySQL using the connection string
5. **Flask Models** = Python classes mapping to MySQL tables
6. **API Routes** = Use models to query database and return data

**The key file is `.env`** - this tells Flask how to find and connect to your MySQL database!
