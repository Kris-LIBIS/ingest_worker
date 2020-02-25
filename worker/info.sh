#!/usr/bin/env bash
docker ps --filter  label=be.libis.teneo.ingester.type=worker --format '{{json .}}'