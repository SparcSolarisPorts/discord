#!/bin/sh
set -eu
FIREFOX=${FIREFOX:-/usr/bin/firefox}
DISCORD_PROFILE=${DISCORD_PROFILE:-"$HOME/.discord-firefox-clean-profile"}
umask 077
mkdir -p "$DISCORD_PROFILE"
chmod 700 "$DISCORD_PROFILE" 2>/dev/null || :
printf '%s\n' \
'user_pref("extensions.enabledScopes", 0);' \
'user_pref("extensions.autoDisableScopes", 15);' \
'user_pref("layers.acceleration.disabled", true);' \
'user_pref("gfx.webrender.all", false);' \
'user_pref("gfx.webrender.enabled", false);' \
'user_pref("gfx.webrender.software", false);' \
'user_pref("dom.webgpu.enabled", false);' \
'user_pref("media.hardware-video-decoding.enabled", false);' \
'user_pref("browser.cache.disk.enable", false);' \
'user_pref("toolkit.cosmeticAnimations.enabled", false);' > "$DISCORD_PROFILE/user.js"
export MOZ_WEBRENDER=0
export MOZ_ACCELERATED=0
exec "$FIREFOX" -new-instance -profile "$DISCORD_PROFILE" 'https://discord.com/app' "$@"
