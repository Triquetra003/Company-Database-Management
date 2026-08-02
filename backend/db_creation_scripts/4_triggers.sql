BEGIN;

CREATE OR REPLACE TRIGGER TR_employees_custom_id BEFORE INSERT ON employees
FOR EACH ROW EXECUTE FUNCTION generate_custom_id();

CREATE OR REPLACE TRIGGER TR_clients_custom_id BEFORE INSERT ON clients
FOR EACH ROW EXECUTE FUNCTION generate_custom_id();

CREATE OR REPLACE TRIGGER TR_products_custom_id BEFORE INSERT ON products
FOR EACH ROW EXECUTE FUNCTION generate_custom_id();

CREATE OR REPLACE TRIGGER TR_documents_custom_id BEFORE INSERT ON documents
FOR EACH ROW EXECUTE FUNCTION generate_custom_id();

CREATE TRIGGER TR_documents_update_timestamp BEFORE UPDATE ON documents
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER TR_employee_auth_update_password_timestamp BEFORE UPDATE OF hash_password ON employee_auth
FOR EACH ROW EXECUTE FUNCTION update_password_timestamp();

COMMIT;