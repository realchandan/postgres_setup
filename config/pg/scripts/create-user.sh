#!/bin/bash
set -e

function create_database() {
    local database="$1"
    local password="$2"

    local username="${database}_user"
    local role="${database}_role"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE ROLE $role NOLOGIN;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE DATABASE $database OWNER $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "REVOKE ALL ON SCHEMA public FROM PUBLIC;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "REVOKE ALL ON DATABASE $database FROM PUBLIC;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT CONNECT ON DATABASE $database TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT ALL PRIVILEGES ON DATABASE $database TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT ALL PRIVILEGES ON SCHEMA public TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$database" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO $role;"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE USER $username WITH ENCRYPTED PASSWORD '$password';"

    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "GRANT $role to $username;"
}

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <database_name> <password>"
    exit 0
fi

create_database "$1" "$2"
