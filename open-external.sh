#!/bin/sh
# Native-messaging host: open a URL outside the Discord Firefox profile.
set -eu

# Native messaging sends a 4-byte little-endian payload length followed by JSON.
length=$(dd bs=1 count=4 2>/dev/null | od -An -tu1 | awk '{ print $1 + 256*$2 + 65536*$3 + 16777216*$4 }')
test -n "$length" || exit 0
payload=$(dd bs=1 count="$length" 2>/dev/null)
url=$(printf '%s' "$payload" | sed -n 's/.*"url"[ 	]*:[ 	]*"\([^"\\]*\).*/\1/p')
test -n "$url" || exit 0

if test -n "${DISCORD_EXTERNAL_OPENER:-}"; then
  "$DISCORD_EXTERNAL_OPENER" "$url" >/dev/null 2>&1 &
elif test -n "${BROWSER:-}"; then
  "$BROWSER" "$url" >/dev/null 2>&1 &
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$url" >/dev/null 2>&1 &
elif command -v gio >/dev/null 2>&1; then
  gio open "$url" >/dev/null 2>&1 &
elif command -v sdtwebclient >/dev/null 2>&1; then
  sdtwebclient "$url" >/dev/null 2>&1 &
elif command -v dtopen >/dev/null 2>&1; then
  dtopen "$url" >/dev/null 2>&1 &
fi
exit 0
