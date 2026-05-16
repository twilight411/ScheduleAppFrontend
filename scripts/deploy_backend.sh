#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   ./scripts/deploy_backend.sh [branch]
# 默认分支: main

BRANCH="${1:-main}"
APP_DIR="/app/spirit-scheduler"
SERVICE_NAME="spirit-scheduler"

echo "[1/4] cd ${APP_DIR}"
cd "${APP_DIR}"

echo "[2/4] git fetch origin"
git fetch origin

echo "[3/4] git checkout ${BRANCH} && reset to origin/${BRANCH}"
git checkout "${BRANCH}"
git reset --hard "origin/${BRANCH}"

echo "[4/4] restart service: ${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"
systemctl --no-pager --full status "${SERVICE_NAME}" | head -n 20

echo "Deploy done."
