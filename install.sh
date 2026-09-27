#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.okdl"

sudo apt update
sudo apt install -y curl ffmpeg python3 python3-venv

mkdir -p "$INSTALL_DIR"

python3 -m venv "$INSTALL_DIR/.venv"

"$INSTALL_DIR/.venv/bin/pip" install --upgrade pip --quiet
"$INSTALL_DIR/.venv/bin/pip" install yt-dlp --quiet

curl -sSL -o "$INSTALL_DIR/okdl.py" https://raw.githubusercontent.com/agb-777/okdl/main/okdl.py
chmod +x "$INSTALL_DIR/okdl.py"

sudo tee /usr/local/bin/okdl > /dev/null <<EOF
#!/usr/bin/env bash

PYTHON_BIN="$INSTALL_DIR/.venv/bin/python3"
SCRIPT_PATH="$INSTALL_DIR/okdl.py"

exec "\$PYTHON_BIN" "\$SCRIPT_PATH" "\$@"
EOF
sudo chmod +x /usr/local/bin/okdl
