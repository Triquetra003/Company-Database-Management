@echo off
set DB_NAME=productManagement
set DB_USER=postgres
set DB_HOST=localhost
set DB_PORT=5432
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\0_cleanup.sql"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\1_functions.sql"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\2_tables.sql"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\3_procedure.sql"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\4_triggers.sql"
psql -h %DB_HOST% -p %DB_PORT% -U %DB_USER% -d %DB_NAME% -f ".\5_initial_data.sql"
pause