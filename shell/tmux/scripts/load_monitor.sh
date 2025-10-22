#!/usr/bin/env bash

# Default threshold (can be overridden by environment variable)
LOAD_THRESHOLD=${TMUX_LOAD_THRESHOLD:-10}

# Get load average (5-minute average is the second value)
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: uptime format is "... load averages: 1min 5min 15min"
  load_5min=$(uptime | awk '{print $(NF-1)}' | tr -d ',')
else
  # Linux: uptime format is "... load average: 1min, 5min, 15min"
  load_5min=$(uptime | awk -F'load average:' '{print $2}' | awk -F', ' '{print $2}')
fi

# Compare load (handle decimals by multiplying by 100)
load_int=$(echo "$load_5min * 100" | bc | cut -d '.' -f 1)
threshold_int=$(echo "$LOAD_THRESHOLD * 100" | bc | cut -d '.' -f 1)

if [[ $load_int -gt $threshold_int ]]; then
  # Style matching the prefix indicator, but with red color
  echo "#[fg=red]#[fg=black bold,bg=red]• HIGH LOAD: $load_5min •#[bg=default,fg=red]#[fg=default]"
fi
