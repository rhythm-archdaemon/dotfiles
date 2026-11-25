#!/bin/sh

# 1. Gracefully terminate any running quickshell instances
killall quickshell 2>/dev/null

# 2. Wait a brief second to ensure ports/processes are completely cleared
sleep 0.5

# 3. Launch quickshell detached in the background
quickshell >/dev/null 2>&1 &

echo "Quickshell has been restarted successfully."
