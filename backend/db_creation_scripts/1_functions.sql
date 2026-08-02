BEGIN;

CREATE OR REPLACE FUNCTION generate_custom_id() RETURNS trigger AS $$
    DECLARE
    t_prefix TEXT;
	t_custom_id TEXT;
	t_column_name TEXT;
    BEGIN
	RAISE NOTICE 'Generating custom id for %', TG_TABLE_NAME;
    SELECT prefix_set INTO t_prefix FROM prefix_settings WHERE table_name=TG_TABLE_NAME;
    t_custom_id:=t_prefix||LPAD(NEW.id::text,4,'0');
	IF TG_TABLE_NAME = 'employees' THEN
		NEW.employee_id:=t_custom_id;
	ELSIF TG_TABLE_NAME = 'clients' THEN
		NEW.client_id:=t_custom_id;
	ELSIF TG_TABLE_NAME = 'products' THEN
		NEW.product_id:=t_custom_id;
	ELSIF TG_TABLE_NAME = 'documents' THEN
		NEW.document_id:=t_custom_id;
    ELSIF TG_TABLE_NAME = 'master_products' THEN
        NEW.master_product_id:=t_custom_id;
	END IF;
	RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_timestamp() RETURNS TRIGGER AS $$
    BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_password_timestamp() RETURNS TRIGGER AS $$
    BEGIN
    NEW.last_password_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

END;