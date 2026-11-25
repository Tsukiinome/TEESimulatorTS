# Runs at install time under Magisk, KernelSU, or APatch.

# The interceptor is a 64-bit library injected into the keystore daemon, which is 64-bit on every
# supported device; refuse 32-bit-only devices rather than fail silently.
if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x64" ]; then
  abort "! TEESimulator requires a 64-bit device"
fi

# TrickyStore intercepts the same keystore path; running both would double-hook it. Disable it via
# its manager's marker (kept, not deleted, so removing us lets the user re-enable it).
for ts in /data/adb/modules/tricky_store /data/adb/modules_update/tricky_store; do
  if [ -d "$ts" ] && [ ! -f "$ts/disable" ]; then
    ui_print "- Disabling TrickyStore (it hooks the same keystore path)"
    touch "$ts/disable"
  fi
done

# Seed the configuration on first install without clobbering existing files.
mkdir -p /data/adb/teesim
# Adopt a keybox the user already set up for TrickyStore when we have none of our own.
if [ ! -f /data/adb/teesim/keybox.xml ] && [ -f /data/adb/tricky_store/keybox.xml ]; then
  ui_print "- Adopting the keybox from TrickyStore"
  cp /data/adb/tricky_store/keybox.xml /data/adb/teesim/keybox.xml
fi
if [ ! -f /data/adb/teesim/config.json ]; then
  cp "$MODPATH/config.default.json" /data/adb/teesim/config.json
  # Carry over the app list from a TrickyStore target.txt. Only plain package names are kept: the
  # per-app "!" / "?" mode suffixes have no per-app equivalent here (the mode is set per profile).
  TS_TARGET=/data/adb/tricky_store/target.txt
  if [ -f "$TS_TARGET" ]; then
    apps=$(tr -d '\r' < "$TS_TARGET" | sed 's/#.*$//; s/[[:space:]]//g; s/[!?]$//' |
      grep -E '^[A-Za-z0-9_.]+$' | sort -u |
      awk 'NF { printf "%s        \"%s\"", (n++ ? ",\n" : ""), $0 } END { print "" }')
    if [ -n "$apps" ]; then
      ui_print "- Adopting the app list from TrickyStore's target.txt"
      awk -v apps="$apps" '
        /"apps": \[/ { print; print apps; skip = 1; next }
        skip && /\]/ { skip = 0 }
        !skip { print }
      ' /data/adb/teesim/config.json > /data/adb/teesim/config.json.new &&
        mv /data/adb/teesim/config.json.new /data/adb/teesim/config.json
    fi
  fi

  # Carry over the GLOBAL patch-level override from a TrickyStore security_patch.txt, if it set
  # one: the lines before its first "[package]" section (a per-package override has no profile to
  # land in here, so those are dropped -- same scope limit as the app-list migration above).
  # Mirrors Config.kt's own precedence (system/vendor/boot each fall back to "all", or to the bare
  # single-line form meaning all three), but only ever writes values that already look like a date:
  # anything else is left blank, which this module reads as "no override, use the real device value"
  # -- the same thing an unset field means in TrickyStore, so a weird line never turns into a
  # surprise override instead of silently doing nothing.
  TS_PATCH=/data/adb/tricky_store/security_patch.txt
  if [ -f "$TS_PATCH" ]; then
    global=$(tr -d '\r' < "$TS_PATCH" | awk '
      /^\[/ { exit }
      { sub(/#.*/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); if (length($0)) print }
    ')
    if [ -n "$global" ]; then
      lines=$(printf '%s\n' "$global" | wc -l)
      eqs=$(printf '%s\n' "$global" | grep -c '=')
      if [ "$lines" -eq 1 ] && [ "$eqs" -eq 0 ]; then
        p_all=$global
      else
        p_all=$(printf '%s\n' "$global" | awk -F= 'tolower($1)=="all"{sub(/^[^=]*=/,"");print;exit}')
        p_system=$(printf '%s\n' "$global" | awk -F= 'tolower($1)=="system"{sub(/^[^=]*=/,"");print;exit}')
        p_vendor=$(printf '%s\n' "$global" | awk -F= 'tolower($1)=="vendor"{sub(/^[^=]*=/,"");print;exit}')
        p_boot=$(printf '%s\n' "$global" | awk -F= 'tolower($1)=="boot"{sub(/^[^=]*=/,"");print;exit}')
      fi
      p_system=${p_system:-$p_all}
      p_vendor=${p_vendor:-$p_all}
      p_boot=${p_boot:-$p_all}
      DATE_RE='^[0-9]{4}-(0[1-9]|1[0-2])(-(0[1-9]|[12][0-9]|3[01]))?$'
      echo "$p_system" | grep -qE "$DATE_RE" || p_system=""
      echo "$p_vendor" | grep -qE "$DATE_RE" || p_vendor=""
      echo "$p_boot" | grep -qE "$DATE_RE" || p_boot=""
      if [ -n "$p_system$p_vendor$p_boot" ]; then
        ui_print "- Adopting the patch levels from TrickyStore's security_patch.txt"
        sed -i "s#\"patchLevel\":.*#\"patchLevel\": { \"system\": \"$p_system\", \"vendor\": \"$p_vendor\", \"boot\": \"$p_boot\" },#" \
          /data/adb/teesim/config.json
      fi
    fi
  fi
fi

# Ship only the ABI this device runs; the other ABI's native libraries are dead weight here.
case "$ARCH" in
  arm64) rm -rf "$MODPATH/x86_64" ;;
  x64) rm -rf "$MODPATH/arm64-v8a" ;;
esac

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/daemon" 0 0 0755
for abi in arm64-v8a x86_64; do
  [ -f "$MODPATH/$abi/inject" ] && set_perm "$MODPATH/$abi/inject" 0 0 0755
  [ -f "$MODPATH/$abi/teesim-uds" ] && set_perm "$MODPATH/$abi/teesim-uds" 0 0 0755
done
