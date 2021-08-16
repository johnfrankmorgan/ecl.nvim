#!/usr/bin/env bash

set -e

docker rm -f hpcc > /dev/null 2>&1 || true
docker run                           \
  -d                                 \
  -p 8002:8002                       \
  -p 8010:8010                       \
  --name hpcc                        \
  --env EXEC_IN_LOOP=true            \
  --env START_SSHD=true              \
  --env START_HPCC=true              \
  --env EXEC_INTERVAL=600            \
  --entrypoint /docker-entrypoint.sh \
  hpccsystems/platform
