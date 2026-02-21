#!/usr/bin/env bash
set -euo pipefail

sdk="sdk:1"
dev="dev:1"

docker build \
  -t "$sdk" \
  -f sdk.Dockerfile \
  .

docker build \
  --build-arg SDK_IMAGE="$sdk" \
  -t "$dev" \
  -f dev.Dockerfile \
  .
