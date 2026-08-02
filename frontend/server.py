import os
import json
from dotenv import load_dotenv
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import psycopg2
from datetime import datetime
from psycopg2 import errors
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError
import time

# Database connection
load_dotenv()
connection = psycopg2.connect(database=os.getenv("DATABASE"), user=os.getenv("USER"), password=os.getenv("PASSWORD"), host=os.getenv("HOST"), port=os.getenv("PORT"))
connection.autocommit = True
cursor = connection.cursor()

app = Flask(__name__)
CORS(app)

passHash=PasswordHasher()


@app.route('/sign_in',methods=['POST'])
def sign_in():
    data=request.get_json(force=True)
    email=data['verifyEmail']
    password=data['verifyPassword']

    cursor.execute("SELECT * FROM employees WHERE email=%s", (email,))
    checkmail = cursor.fetchone()
    if not checkmail:
       return {"status":"User does not exist!"}
     

    cursor.execute("SELECT auth.hash_password,auth.needs_password_change FROM employees AS emp JOIN employee_auth AS auth ON emp.id=auth.employee_id WHERE emp.email=%s",(email,))
    rows = cursor.fetchall()
    for row in rows:
        hashed_password = row[0]      
        pass_expired = row[1]
    if hashed_password:
        if pass_expired:
            print("Password for",email,"is expired. Reset!")
            return {"status": "Password Expired! Reset password to Continue"}
        # cursor.execute
        try:
            passHash.verify(hashed_password,password)
            print("success")
            return {"status":"success"}
        except VerifyMismatchError:
            return {"status":"Incorrect Password!"}
    else:
        return {"status":"Failed to verify password!"}

@app.route('/new_employee', methods=['POST'])
def new_employee():
    data=request.get_json(force=True)
    
    first_name = data['employeeFirstName']
    last_name = data['employeeLastName']
    email = data['employeeEmail']
    address = data['employeeAddress']
    password=data['employeePassword']
    hashed_password=passHash.hash(password)
    # contact_number = data['employeeContact']
    department = data['employeeDepartment']
    designation = data['employeeDesignation']
    # get department_id and role_id from database
    cursor.execute("SELECT id FROM departments WHERE name ILIKE %s",(department,))
    result=cursor.fetchone()
    department_id = result[0] if result else None
    cursor.execute("SELECT id FROM roles WHERE name ILIKE %s",(designation,))
    result=cursor.fetchone()
    print(designation,result)
    role_id = result[0] if result else None
    # insert employee data into database
    cursor.execute("INSERT INTO employees(first_name, last_name, email,address,department_id, role_id) VALUES (%s, %s, %s, %s, %s, %s);",
                   (first_name, last_name, email, address, department_id, role_id))
    cursor.execute("INSERT INTO employee_auth(employee_id, hash_password) VALUES ((SELECT id FROM employees WHERE email=%s), %s);",(email, hashed_password))
    connection.commit() 
    print("Inserted new employee into database!")
    return jsonify({"status": "Inserted new employee into database!"}), 200

@app.route('/new_client', methods=['POST'])
def new_client():
    data=request.get_json(force=True)
    
    client_name = data['clientName']
    client_address = data['clientAddress']
    client_contact = data['clientContact']
    client_product = data['clientProduct']
    cursor.execute("SELECT id FROM products WHERE product_id=%s",(client_product,));
    result=cursor.fetchone()
    print("result",result)
    if result:
        product_id=result[0]
        cursor.execute("INSERT INTO clients(client_name, address, contact_number) VALUES (%s, %s, %s);",(client_name, client_address, client_contact))
        # cursor.execute("INSERT INTO clients_products(client_id, product_id) VALUES ((SELECT id FROM clients WHERE client_name=%s), (SELECT id FROM products WHERE product_id=%s));",(client_name, client_product))
        connection.commit() 
        print("Inserted new client into database!")
        return jsonify({"status": "Inserted new client into database!"}), 200
    else:
        return jsonify({"status": "Product Not Found"}), 400

@app.route('/new_product', methods=['POST'])
def new_product():
    form=request.form.get('data')
    data=json.loads(form)
    file=request.files.get('productFile')
    path = os.getenv("DOC_PATH")
    file = request.files.get('productFile')
    saved_filename=None
    filename=None

    if file:
        filename=file.filename
        ext = os.path.splitext(file.filename)[1]
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        saved_filename=f"{timestamp}{ext}"
        full_path = os.path.join(path, saved_filename)
        file.save(full_path)
    
    product_name = data.get('productName')
    product_number = data.get('productNumber')

    try:
        cursor.execute("INSERT INTO products(model_number,product_name) VALUES (%s, %s);",(product_number,product_name))
        cursor.execute("INSERT INTO documents(document_name, document_path, reference_table, reference_id) VALUES (%s, %s, %s, (SELECT id FROM products WHERE model_number=%s));",(filename, saved_filename, 'products', product_number))
        connection.commit() 
        print("Inserted new product into database!")
        return jsonify({"status": "Product Added"}), 200
    except errors.UniqueViolation:
        print("Product Already Exists")
        return jsonify({"status":"Product Already Exists"})

@app.route('/search_results', methods=['POST'])
def search_results():
    data=request.get_json(force=True)
    table_name = data['table']
    field_value=data.get('field') or None
    product_name=data.get('product_name')

    field_name={
            'employees':'email',
            'clients':'client_name',
            'products':'product_name'
        }

    like_field_value=f"%{field_value}%"

    if field_value and table_name=='products':
        cursor.execute(f'SELECT p.id,p.product_id,p.model_number,p.product_name,d.document_path FROM products p LEFT JOIN documents d ON p.id = d.reference_id WHERE d.reference_table = \'products\' AND {field_name[table_name]} ILIKE %s ;',(like_field_value,))

    elif field_value is None and table_name=='products':
        cursor.execute(f'SELECT p.id,p.product_id,p.model_number,p.product_name,d.document_path,p.created_at FROM products p LEFT JOIN documents d ON p.id = d.reference_id WHERE d.reference_table = \'products\';')

    elif field_value and table_name=='clients':
        cursor.execute(f'SELECT id,client_id,client_name,contact_number,address,created_at FROM {table_name} WHERE {field_name[table_name]} ILIKE %s ;',(like_field_value,)) 

    elif field_value is None and table_name=='clients':
        cursor.execute(f'SELECT id,client_id,client_name,contact_number,address,created_at FROM {table_name};')

    elif field_value and table_name=='employees':
        cursor.execute('SELECT id,employee_id,first_name, last_name, email,address,department_id,role_id,created_at FROM employees WHERE first_name ILIKE %s OR last_name ILIKE %s OR CONCAT(first_name,%s,last_name) ILIKE %s;',(like_field_value,like_field_value,' ',like_field_value,))

    # elif product_name and table_name=='productWiseClients':
    #     cursor.execute('SELECT client_id FROM clients_products WHERE product_id=(SELECT id FROM products WHERE product_id=%s);',(product_name,))
    #     client_ids=cursor.fetchone()
    #     if client_ids:
    #         for client_id in client_ids:
    #             cursor.execute('SELECT id,client_id,client_name,created_at FROM clients WHERE id=%s;', (client_id,))
    
    elif table_name=='employees' and field_value==None:
        cursor.execute('SELECT id,employee_id,first_name, last_name, email,address,department_id,role_id,created_at FROM employees;')
    else:
        cursor.execute(f"SELECT * FROM {table_name};")

    rows = []
    for row in cursor.fetchall():
        rows.append(row)

    print("Search query. Data returned!")
    return jsonify(rows), 200

@app.route('/get_doc_path/<path:filename>')
def get_doc_path(filename):
    print(filename)
    path = os.path.normpath(os.getenv("DOC_PATH"))
    return send_from_directory(path, filename)

@app.route('/product_list',methods=['GET'])
def product_list():
    cursor.execute("SELECT id,product_id,model_number,product_name FROM products;")
    rows=[]
    for row in cursor.fetchall():
        rows.append(row)
    return jsonify(rows),200

# def check_pass_reset():
#     while True:
#         cursor.execute("UPDATE employees SET pass_expired = TRUE WHERE pass_expired = FALSE AND last_pass_change < NOW() - INTERVAL '1 hour';")
#         connection.commit()
#         print("Check for expired passwords!")
#         time.sleep(60)

# check_pass_reset()

if __name__ == "__main__":
    app.run(debug=True, port=5000)