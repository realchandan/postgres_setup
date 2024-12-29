#!/bin/bash
set -e

password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64)

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE USER pgbouncer WITH ENCRYPTED PASSWORD '$password';"

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "
CREATE
OR REPLACE FUNCTION user_search (uname TEXT) RETURNS TABLE (usename name, passwd text) as \$\$
    SELECT
        usename,
        passwd
    FROM
        pg_shadow
    WHERE
        usename = uname;
\$\$ LANGUAGE sql SECURITY DEFINER;
"
