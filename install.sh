#!/bin/sh
# Install the chrome-free Discord Firefox client for the current user.
set -eu

SOURCE_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
DATA_DIR=${DISCORD_INSTALL_DIR:-"$HOME/.local/share/discord-client"}
BIN_DIR=${XDG_BIN_HOME:-"$HOME/.local/bin"}
APP_DIR=${XDG_DATA_HOME:-"$HOME/.local/share"}/applications
NATIVE_DIR=${FIREFOX_NATIVE_MESSAGING_DIR:-"$HOME/.mozilla/native-messaging-hosts"}

mkdir -p "$DATA_DIR" "$BIN_DIR" "$APP_DIR" "$NATIVE_DIR"
chmod 700 "$DATA_DIR" 2>/dev/null || :

for file in manifest.json content.js background.js launch-firefox.sh open-external.sh README.md; do
  test -f "$SOURCE_DIR/$file" || {
    echo "missing required file: $SOURCE_DIR/$file" >&2
    exit 1
  }
  cp "$SOURCE_DIR/$file" "$DATA_DIR/$file"
done
chmod 755 "$DATA_DIR/launch-firefox.sh" "$DATA_DIR/open-external.sh"

cat > "$BIN_DIR/discord-client" <<EOF
#!/bin/sh
exec "$DATA_DIR/launch-firefox.sh" "\$@"
EOF
chmod 755 "$BIN_DIR/discord-client"

cat > "$NATIVE_DIR/discord_client.json" <<EOF
{
  "name": "discord_client",
  "description": "Open Discord external URLs in the normal browser",
  "path": "$DATA_DIR/open-external.sh",
  "type": "stdio",
  "allowed_extensions": [ "discord-client@localhost" ]
}
EOF
chmod 644 "$NATIVE_DIR/discord_client.json"

cat > "$APP_DIR/discord-client.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Discord Client
Comment=Discord in a normal decorated Firefox window
Exec=$BIN_DIR/discord-client
Terminal=false
Categories=Network;Chat;
EOF
chmod 644 "$APP_DIR/discord-client.desktop"

echo "Installed Discord client to $DATA_DIR"
echo "Launcher: $BIN_DIR/discord-client"
echo "Native host: $NATIVE_DIR/discord_client.json"
echo "Desktop entry: $APP_DIR/discord-client.desktop"
