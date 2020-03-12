#!/usr/bin/env bash

set -e

echo "CREATE USER ${DB_USER} WITH CREATEDB " | psql -v ON_ERROR_STOP=1 --username "$DB_USER" --password "$DB_PASSWORD" --dbname "$POSTGRES_DB"
