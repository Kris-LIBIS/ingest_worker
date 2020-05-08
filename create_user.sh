#!/usr/bin/env bash

psql -d postgres -U ${POSTGRES_USER} -c "CREATE ROLE ${DB_USER} WITH LOGIN CREATEDB PASSWORD '${DB_PASSWORD}';"
psql -d postgres -U ${POSTGRES_USER} -c "CREATE DATABASE ${DB_NAME} WITH OWNER ${DB_USER};"
