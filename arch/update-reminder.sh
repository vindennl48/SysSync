#!/bin/bash

timestamp_file="/var/lib/last_update_reminder"
one_week=$((7 * 24 * 60 * 60))  # 7 days in seconds

# Check if timestamp file exists
if [ ! -f "$timestamp_file" ]; then
    echo "⚠️ Reminder: System never updated! Run 'sudo pacman -Syu'"
    exit 0
fi

# Get timestamps
last_update=$(cat "$timestamp_file")
current_time=$(date +%s)
time_diff=$((current_time - last_update))

# Check time difference
if [ "$time_diff" -gt "$one_week" ]; then
    echo "⚠️ Reminder: System not updated in over 7 days!"
    echo "   Run: sudo pacman -Syu"
fi
