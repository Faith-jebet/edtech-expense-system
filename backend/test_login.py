import requests

try:
    response = requests.post('http://127.0.0.1:5000/api/v1/auth/login', json={
        "email": "admin@example.com",
        "password": "password"
    })
    print("Status:", response.status_code)
    print("Response:", response.text)
except Exception as e:
    print("Error:", e)
