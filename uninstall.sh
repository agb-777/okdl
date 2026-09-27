#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run as root!"
    exit 1
fi

INSTALL_DIR="$HOME/.okdl"

rm -f /usr/local/bin/okdl
rm -rf "$INSTALL_DIR"

echo "[+] okdl has been successfully uninstalled."
