#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run as root!"
    exit 1
fi

INSTALL_DIR="$HOME/.okdl"

apt update
apt install -y curl ffmpeg python3 python3-venv

mkdir -p "$INSTALL_DIR"

python3 -m venv "$INSTALL_DIR/.venv"

"$INSTALL_DIR/.venv/bin/pip" install --upgrade pip --quiet
"$INSTALL_DIR/.venv/bin/pip" install yt-dlp --quiet

curl -sSL -o "$INSTALL_DIR/okdl.py" https://raw.githubusercontent.com/agb-777/okdl/main/okdl.py
chmod +x "$INSTALL_DIR/okdl.py"

tee /usr/local/bin/okdl > /dev/null <<EOF
#!/usr/bin/env bash

PYTHON_BIN="$INSTALL_DIR/.venv/bin/python3"
SCRIPT_PATH="$INSTALL_DIR/okdl.py"

exec "\$PYTHON_BIN" "\$SCRIPT_PATH" "\$@"
EOF
chmod +x /usr/local/bin/okdl

echo "[+] okdl has been successfully installed. Run 'okdl <url>' to get started."
