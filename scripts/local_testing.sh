#!/usr/bin/env bash
# Local manual testing — user app, partner app, admin, backend on LAN IP
set -euo pipefail

LAN_IP="${LAN_IP:-$(hostname -I | awk '{print $1}')}"
API_URL="http://${LAN_IP}:5678"

echo "Using LAN IP: ${LAN_IP}"
echo "API URL:      ${API_URL}"
echo ""

case "${1:-help}" in
  backend)
    echo "Starting backend (listens on 0.0.0.0:5678)..."
    cd /home/vikalp/pproject/Gloup-Test-Backend
    export LAN_HOST="${LAN_IP}"
    npm run start:host
    ;;
  admin)
    echo "Starting admin panel at http://${LAN_IP}:5173"
    cd /home/vikalp/pproject/Gloup-Test-AdminPanel
    npm run dev
    ;;
  user)
    echo "Starting user app → ${API_URL}"
    cd /home/vikalp/pproject/gloup_user
    flutter run --dart-define=API_BASE_URL="${API_URL}" "${@:2}"
    ;;
  partner)
    echo "Starting partner app → ${API_URL}"
    cd /home/vikalp/pproject/gloup_partner
    flutter run --dart-define=API_BASE_URL="${API_URL}" "${@:2}"
    ;;
  help|*)
    cat <<EOF
Usage: $0 <command> [extra flutter args]

Commands:
  backend   Start local API (MySQL must be running)
  admin     Start admin panel on http://${LAN_IP}:5173
  user      Run user Flutter app against ${API_URL}
  partner   Run partner Flutter app against ${API_URL}

Setup once:
  1. Backend .env — point DEV_DB_* to your local MySQL
  2. Backend .env — add LAN_HOST=${LAN_IP}
  3. Admin .env.local — VITE_API_BASE_URL=${API_URL}
  4. Phone/emulator on same Wi‑Fi as this machine

Quick checks:
  curl ${API_URL}/status
  Open http://${LAN_IP}:5173 in browser (admin)
EOF
    ;;
esac
