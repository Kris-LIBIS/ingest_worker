#!/usr/bin/env bash
docker stop ingest_worker.$1
docker rm ingest_worker.$1