#!/bin/bash

# Simple process monitor script
# Usage: ./monitor.sh <program>

if [ $# -eq 0 ]; then
    echo "Error: Please specify a program to monitor"
    echo "Example: ./monitor.sh firefox"
    exit 1
fi

PROGRAM=$1
LOG_FILE="usage.log"
PLOT_FILE="usage.png"

echo "Starting monitor for: $PROGRAM"

# Start the program
$PROGRAM &
PID=$!
echo "Program started with PID: $PID"

# Create log file header
echo "Time CPU Memory" > $LOG_FILE

# Main monitoring loop
while true; do
    # Check if process still exists
    if ! ps -p $PID > /dev/null; then
        echo "Program has finished"
        break
    fi
    
    # Get current time
    CURRENT_TIME=$(date +"%H:%M:%S")
    
    # Get CPU and Memory usage
    USAGE=$(ps -p $PID -o %cpu,%mem --no-headers)
    
    # Write to log file
    echo "$CURRENT_TIME $USAGE" >> $LOG_FILE
    
    # Wait 1 second
    sleep 1
done

echo "Generating plot..."

# Simple plot using gnuplot
echo "set terminal png
set output '$PLOT_FILE'
set title 'Resource Usage for $PROGRAM'
set xlabel 'Time'
set ylabel 'Usage (%)'
plot '$LOG_FILE' using 2 with lines title 'CPU %', \
     '$LOG_FILE' using 3 with lines title 'Memory %'" | gnuplot

echo "Done! Plot saved as $PLOT_FILE"
echo "Raw data saved as $LOG_FILE"
