#!/bin/bash

WATCH_DIR="/home/$(whoami)/watch_folder"
LOG_FILE="/home/$(whoami)/monitor_log.txt"

if ! command -v inotifywait >/dev/null; then
    echo "ERROR: Install inotify-tools first: sudo apt install inotify-tools"
    exit 1
fi

mkdir -p "$WATCH_DIR"
touch "$LOG_FILE"

echo "Monitoring $WATCH_DIR (Log: $LOG_FILE)"
echo "Press Ctrl+C to stop..."

inotifywait -m -r -q --format '%T %e %w%f' --timefmt '%F %T' "$WATCH_DIR" | while read -r line; do
    echo "[$(date '+%F %T')] $line" | tee -a "$LOG_FILE"
done
