from app import create_app, db
from sqlalchemy import text

app = create_app()

with app.app_context():
    try:
        # Alter income_receipts
        db.session.execute(text("ALTER TABLE income_receipts ADD COLUMN proof_attachment_id INT NULL;"))
        db.session.execute(text("ALTER TABLE income_receipts ADD CONSTRAINT fk_income_attachment FOREIGN KEY (proof_attachment_id) REFERENCES attachments(id) ON DELETE SET NULL;"))
        print("Added proof_attachment_id to income_receipts")
    except Exception as e:
        print("income_receipts proof_attachment_id error (might already exist):", e)
        
    try:
        db.session.execute(text("ALTER TABLE income_receipts ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;"))
        print("Added updated_at to income_receipts")
    except Exception as e:
        print("income_receipts updated_at error:", e)

    try:
        # Alter reconciliations
        db.session.execute(text("ALTER TABLE reconciliations ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;"))
        db.session.execute(text("ALTER TABLE reconciliations ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;"))
        print("Added created_at and updated_at to reconciliations")
    except Exception as e:
        print("reconciliations timestamp error:", e)
        
    db.session.commit()
    print("Database schema successfully patched.")
