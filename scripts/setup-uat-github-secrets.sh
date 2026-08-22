#!/usr/bin/env bash
# Configure GitHub Actions secrets for UAT deploy (run locally after `gh auth login`)
set -euo pipefail

GH="${GH:-$HOME/.local/bin/gh}"
UAT_IP="${UAT_IP:-169.58.105.116}"
SSH_USER="${UAT_SSH_USER:-root}"
SSH_KEY_FILE="${UAT_SSH_KEY_FILE:-$HOME/.ssh/id_ed25519_virtualsphere}"

if [ ! -x "$GH" ]; then
  echo "Install GitHub CLI first: https://cli.github.com/"
  exit 1
fi

if [ ! -f "$SSH_KEY_FILE" ]; then
  echo "SSH private key not found: $SSH_KEY_FILE"
  exit 1
fi

read -r -p "Admin UAT API URL [http://${UAT_IP}:5678]: " ADMIN_UAT_API
ADMIN_UAT_API="${ADMIN_UAT_API:-http://${UAT_IP}:5678}"
read -r -p "Admin UAT image base URL [https://storage.googleapis.com/gloup-images]: " ADMIN_UAT_IMG
ADMIN_UAT_IMG="${ADMIN_UAT_IMG:-https://storage.googleapis.com/gloup-images}"
read -r -p "Google Maps key: " ADMIN_UAT_MAPS
read -r -p "Admin UAT port [3002]: " ADMIN_UAT_PORT
ADMIN_UAT_PORT="${ADMIN_UAT_PORT:-3002}"

for REPO in Virtualsphere/Gloup-Test-Backend Virtualsphere/Gloup-Test-AdminPanel; do
  "$GH" secret set UAT_SERVER_IP --repo "$REPO" --body "$UAT_IP"
  "$GH" secret set UAT_SSH_USER --repo "$REPO" --body "$SSH_USER"
  "$GH" secret set UAT_SSH_KEY --repo "$REPO" < "$SSH_KEY_FILE"
  echo "UAT SSH secrets set for $REPO"
done

"$GH" secret set ADMIN_UAT_API_BASE_URL --repo Virtualsphere/Gloup-Test-AdminPanel --body "$ADMIN_UAT_API"
"$GH" secret set ADMIN_UAT_IMAGE_BASE_URL --repo Virtualsphere/Gloup-Test-AdminPanel --body "$ADMIN_UAT_IMG"
"$GH" secret set ADMIN_UAT_GOOGLE_MAPS_KEY --repo Virtualsphere/Gloup-Test-AdminPanel --body "$ADMIN_UAT_MAPS"
"$GH" secret set ADMIN_UAT_PORT --repo Virtualsphere/Gloup-Test-AdminPanel --body "$ADMIN_UAT_PORT"

echo "Done. Verify with: $GH secret list --repo Virtualsphere/Gloup-Test-AdminPanel"
