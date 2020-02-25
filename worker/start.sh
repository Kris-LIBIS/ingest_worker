#!/usr/bin/env bash
docker run -d -e NAME=$1 --name ingest_worker.$1 --label be.libis.teneo.ingester.name=$1 --restart unless-stopped ingest_worker:latest