#!/bin/sh

CONFIG_FILE=~/.config/openfortivpn/config
PW_UUID_FILE=~/.config/openfortivpn/pw_uuid
OP_SESSION_FILE=~/.op-session

if pgrep -x openfortivpn > /dev/null; then
  echo "VPN already running."
  sleep 3
  exit
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "No config file at $CONFIG_FILE"
  sleep 3
  exit 1
fi

if ! grep "^password" "$CONFIG_FILE" > /dev/null; then
  if command -v op >/dev/null && [ -f "$PW_UUID_FILE" ]; then
    if [ -f "$OP_SESSION_FILE" ]; then
      OP_SESSION=$(cat ~/.op-session)
      OP_SESSION=$(op signin my --raw --session "$OP_SESSION")
    else
      OP_SESSION=$(op signin my --raw)
    fi

    echo "$OP_SESSION" > "$OP_SESSION_FILE"

    PW_UUID=$(cat "$PW_UUID_FILE")

    PASSWORD=$(op get item "$PW_UUID" --fields password --session "$OP_SESSION")

    PASSWORD_FLAG="--password=$PASSWORD"
  fi
fi

sudo openfortivpn -c "$CONFIG_FILE" $PASSWORD_FLAG
