#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$PSP_POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE app_test_db
      WITH
      OWNER = $APP_POSTGRES_USER
      ENCODING = 'UTF8'
      CONNECTION LIMIT = -1
      IS_TEMPLATE = False;

  GRANT ALL ON DATABASE app_test_db TO $APP_POSTGRES_USER;
EOSQL
