INSERT INTO prefix_settings(table_name, prefix_set) VALUES
('employees','EL'),
('clients','CLS'),
('products','PO'),
('tickets','TI'),
('documents','DO'),
('master_products','MP')
ON CONFLICT (table_name) DO NOTHING;

INSERT INTO departments(name) VALUES
('Sales'),('Accounting'),('Human Resources'),('Marketing'),('IT');

INSERT INTO roles(name) VALUES
('Manager'),('Junior Executive'),('Senior Executive'),('Worker');

INSERT INTO client_status(name) VALUES
('Existing'),('Old'),('In-Progress'),('Confirmed'),('Potential');

INSERT INTO communication_modes(mode, key, server, fax_number) VALUES
('Email', 'email_key', 'smtp.example.com', null),
('Phone', 'phone_key', null, null),
('Fax', 'fax_key', null, '123-456-7890');

-- INSERT INTO backup_logs(backup_type,postgres_dump_status, backup_status) VALUES
-- ('full_backup', 'success', 'success'),
-- ('full_backup', 'failure', 'success'),
-- ('syncing', null, 'failure'),
-- ('syncing', null , 'success');