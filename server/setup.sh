#!/usr/bin/env bash

# grab container id for the db
CONT_ID=$(docker container ls | grep "ingest_server" | awk '{print $1}')

# Generate key file
docker exec $CONT_ID bundle exec irb -r 'securerandom' \
    -e "File.write(File.join(Teneo::IngestServer::ROOT_DIR, 'key.bin'), SecureRandom.random_bytes(64), mode: 'wb')"

# Setup the database
docker exec $CONT_ID bundle exec rake teneo:db:recreate
