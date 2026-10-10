from app import create_app, db

app = create_app()
with app.app_context():
    try:
        from sqlalchemy import text
        result = db.session.execute(text("SHOW CREATE TABLE payments;"))
        for row in result:
            print(row[1])
    except Exception as e:
        print("Error:", e)
