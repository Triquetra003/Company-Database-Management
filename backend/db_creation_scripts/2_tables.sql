BEGIN;

-- prefix 

CREATE TABLE IF NOT EXISTS prefix_settings(
    table_name VARCHAR(50) PRIMARY KEY,
    prefix_set VARCHAR(20) NOT NULL UNIQUE
);

-- lookup tables

CREATE TABLE IF NOT EXISTS departments(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS roles(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS user_pass_config(
	min_length INT,
	min_numeric_count INT,
	min_character_count INT,
	min_special_character_count INT
);

CREATE TABLE IF NOT EXISTS client_status(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS communication_modes(
	id SERIAL PRIMARY KEY,
	mode VARCHAR(50) NOT NULL UNIQUE,
	key VARCHAR(255) NOT NULL UNIQUE,
	server VARCHAR(255),
	fax_number VARCHAR(20)
);

-- documents

CREATE TABLE IF NOT EXISTS documents(
	id BIGSERIAL PRIMARY KEY,
	document_id VARCHAR(50) UNIQUE,
	document_name VARCHAR(100) NOT NULL,
	document_path TEXT NOT NULL UNIQUE,
	reference_table VARCHAR(50),
	reference_id INT,
	document_version NUMERIC DEFAULT 1.0,
	uploaded_by INT,
	uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	updated_by INT,
	updated_at TIMESTAMPTZ,
	notes TEXT
);

-- Employee

CREATE TABLE IF NOT EXISTS employees(
    id BIGSERIAL PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(255) NOT NULL,
	address TEXT,
	department_id INT REFERENCES departments(id) ON DELETE SET NULL,
	role_id INT REFERENCES roles(id) ON DELETE SET NULL,
	document_id INT REFERENCES documents(id) ON DELETE SET NULL,
	notes TEXT,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS employee_auth(
	id BIGSERIAL PRIMARY KEY,
	employee_id INT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
	hash_password VARCHAR(255) NOT NULL UNIQUE,
	last_password_updated TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	needs_password_change BOOLEAN DEFAULT FALSE,
	document_id INT REFERENCES documents(id) ON DELETE SET NULL,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- client

CREATE TABLE IF NOT EXISTS clients(
	id BIGSERIAL PRIMARY KEY,
	client_id VARCHAR(20) UNIQUE,
	client_name VARCHAR(50) NOT NULL,
	status_id INT REFERENCES client_status(id) ON DELETE SET NULL, 
	department_id INT REFERENCES departments(id) ON DELETE SET NULL,
	contact_number VARCHAR(20),
	address TEXT,
	notes TEXT,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- product

CREATE TABLE IF NOT EXISTS products(
	id BIGSERIAL PRIMARY KEY,
	product_id VARCHAR(20) UNIQUE,
	model_number VARCHAR(20) NOT NULL UNIQUE,
	product_name VARCHAR(50)NOT NULL,
	product_version NUMERIC, 
	price NUMERIC,
	currency TEXT DEFAULT 'USD', 
	is_verified BOOLEAN DEFAULT FALSE,
	department_id INT REFERENCES departments(id) ON DELETE SET NULL,
	notes TEXT,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- communications
CREATE TABLE IF NOT EXISTS communication_logs(
	id BIGSERIAL PRIMARY KEY,
	external_id VARCHAR(50) UNIQUE,
	category VARCHAR(50) NOT NULL CHECK (category IN ('internal', 'external')),
	communication_mode_id INT NOT NULL REFERENCES communication_modes(id) ON DELETE SET NULL,
	communication_subject VARCHAR(100) NOT NULL,
	communication_from VARCHAR(255) NOT NULL,
	communication_to VARCHAR(255) NOT NULL,
	cc VARCHAR(255),
	data_message TEXT NOT NULL,
	response_message TEXT,
	notification_status VARCHAR(50) CHECK (notification_status IN ('pending', 'sent', 'null', 'success')) DEFAULT 'null',
	sent_at TIMESTAMPTZ,
	notes TEXT,
	created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- deliveries
CREATE TABLE IF NOT EXISTS deliveries(
	id BIGSERIAL PRIMARY KEY,
	tracking_number VARCHAR(50) UNIQUE,
	client_id INT NOT NULL REFERENCES clients(id) ON DELETE SET NULL,
	dispatched_at TIMESTAMPTZ NOT NULL,
	vehicle_details TEXT,
	notes TEXT
);

COMMIT;