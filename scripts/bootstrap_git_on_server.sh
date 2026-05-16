#!/usr/bin/env bash
set -euo pipefail

# 用法:
#   REPO_URL=https://github.com/<owner>/<repo>.git ./scripts/bootstrap_git_on_server.sh
# 可选:
#   BRANCH=main APP_DIR=/app/spirit-scheduler SERVICE_NAME=spirit-scheduler

: "${REPO_URL:?REPO_URL is required}"
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-/app/spirit-scheduler}"
SERVICE_NAME="${SERVICE_NAME:-spirit-scheduler}"
BACKUP_DIR="/app/spirit-scheduler-backup-$(date +%Y%m%d-%H%M%S)"
TMP_CLONE="/tmp/spirit-scheduler-clone-$$"

echo "[1/7] backup current app dir -> ${BACKUP_DIR}"
cp -a "${APP_DIR}" "${BACKUP_DIR}"

echo "[2/7] clone ${REPO_URL}#${BRANCH} to temp"
git clone -b "${BRANCH}" "${REPO_URL}" "${TMP_CLONE}"

echo "[3/7] preserve runtime files"
if [[ -f "${APP_DIR}/.env" ]]; then cp -a "${APP_DIR}/.env" "${TMP_CLONE}/.env"; fi
if [[ -f "${APP_DIR}/spirit.db" ]]; then cp -a "${APP_DIR}/spirit.db" "${TMP_CLONE}/spirit.db"; fi
if [[ -d "${APP_DIR}/web_build" ]]; then
  rm -rf "${TMP_CLONE}/web_build"
  cp -a "${APP_DIR}/web_build" "${TMP_CLONE}/web_build"
fi

echo "[4/7] replace app dir"
mv "${APP_DIR}" "${APP_DIR}.old.$(date +%s)"
mv "${TMP_CLONE}" "${APP_DIR}"

echo "[5/7] restart service"
systemctl restart "${SERVICE_NAME}"

echo "[6/7] verify service status"
systemctl --no-pager --full status "${SERVICE_NAME}" | head -n 20

echo "[7/7] done. backup at ${BACKUP_DIR}"
