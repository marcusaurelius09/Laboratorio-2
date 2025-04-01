#!/bin/bash

# Process Resource Monitor
# Usage: ./monitor.sh <command-to-monitor>

# Verify command argument
if [ $# -eq 0 ]; then
    echo "Error: Please specify a program to monitor"
    echo "Example: ./monitor.sh firefox"
    exit 1
fi

PROGRAM=$1
LOG_FILE="usage.log" 
PLOT_FILE="usage.png"

echo "=== Process Monitoring Started ==="
echo "Monitoring target: $PROGRAM"

# Verify program exists
if ! command -v "$PROGRAM" >/dev/null 2>&1; then
    echo "Error: Program '$PROGRAM' not found in PATH"
    exit 1
fi

# Launch the program
echo "Launching process..."
$PROGRAM &
PID=$!
echo "Process started with PID: $PID"

# Initialize log file
echo "Timestamp CPU% Memory%" > "$LOG_FILE"

# Monitoring loop
echo -e "\n=== Monitoring Resources ==="
while ps -p "$PID" >/dev/null 2>&1; do
    echo "$(date +"%T") $(ps -p "$PID" -o %cpu=,%mem=)" >> "$LOG_FILE"
    sleep 1
done

echo -e "\n=== Process Completed ==="

# Generate visualization
echo "Generating resource usage plot..."
gnuplot <<EOF
set terminal png
set output "$PLOT_FILE"
set title "Resource Usage: $PROGRAM"
set xlabel "Time"
set ylabel "Usage (%)"
set grid
plot "$LOG_FILE" using 2 with lines title "CPU", \
     "$LOG_FILE" using 3 with lines title "Memory"
EOF

# Final report
echo -e "\n=== Monitoring Results ==="
echo "1. Raw data saved to: $LOG_FILE"
echo "   Sample data:"
head -n 5 "$LOG_FILE" | column -t
echo -e "\n2. Visualization saved to: $PLOT_FILE"
echo "   To view: xdg-open $PLOT_FILE"
echo -e "\n=== Monitoring Complete ==="
