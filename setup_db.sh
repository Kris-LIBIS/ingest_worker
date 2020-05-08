#!/usr/bin/env bash

# load .env files
# set -o allexport
[[ -f .db_credentials.env ]] && source .env
[[ -f .dba_credentials.env ]] && source .env
# set +o allexport

# grab container id for the db
CONT_ID=$(docker container ls | grep "teneo_db" | awk '{print $1}')

# create db user
docker exec $CONT_ID psql -d postgres -U ${POSTGRES_USER} -c "CREATE ROLE ${DB_USER} WITH LOGIN CREATEDB PASSWORD '${DB_PASSWORD}';"

# create new database
docker exec $CONT_ID psql -d postgres -U ${POSTGRES_USER} -c "CREATE DATABASE ${DB_NAME} WITH OWNER ${DB_USER};"
