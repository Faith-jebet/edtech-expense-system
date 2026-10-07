"""Test creating an expense request."""
import requests
import json

# Login first
login_response = requests.post('http://localhost:5000/api/v1/auth/login', json={
    'email': 'manager@milestone.com',
    'password': 'role123'
})

print("Login response:", login_response.status_code)
if login_response.status_code == 200:
    token = login_response.json()['access_token']
    print("✅ Login successful!")
    print(f"Token: {token[:50]}...")
    
    # Try to create request
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/json'
    }
    
    request_data = {
        'project_id': 1,
        'category_id': 1,
        'priority': 'Normal',
        'payee_name': 'Test Supplier',
        'payee_details': 'Bank Account: 123456',
        'currency': 'USD',
        'business_justification': 'Testing expense request creation process',
        'payment_method': 'Bank Transfer',
        'budget_status': 'Within Budget',
        'is_advance': False,
        'items': [
            {
                'description': 'Test item 1',
                'quantity': '2',
                'unit_cost': '50.00'
            }
        ]
    }
    
    print("\nCreating request...")
    create_response = requests.post(
        'http://localhost:5000/api/v1/expense-requests',
        headers=headers,
        json=request_data
    )
    
    print(f"Create response: {create_response.status_code}")
    print(f"Response text: {create_response.text}")
    if create_response.status_code == 201:
        print(f"Response body: {json.dumps(create_response.json(), indent=2)}")
    else:
        print("❌ Request creation failed")
    
else:
    print(f"❌ Login failed: {login_response.json()}")
