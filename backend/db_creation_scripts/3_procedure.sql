CREATE OR REPLACE PROCEDURE check_password_expiry()
LANGUAGE plpgsql
AS $$
BEGIN
UPDATE employee_auth SET needs_password_change = TRUE WHERE needs_password_change = FALSE AND last_password_updated < NOW() - INTERVAL '15 days';
RAISE NOTICE 'Password expiry check completed.';
END;
$$;