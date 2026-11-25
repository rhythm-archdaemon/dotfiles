#!/usr/bin/env bash
# reload-quickshell.sh — safe restart for this config.
#   ./reload-quickshell.sh        restart in the background, log to $XDG_STATE_HOME/quickshell-reload.log
#   ./reload-quickshell.sh -f     restart in the foreground (errors print to this terminal)
#
# Quickshell already hot-reloads when a file changes; use this when it hangs,
# a singleton got stuck, or you changed something a hot reload doesn't pick up.

set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell-reload.log"
FOREGROUND=0
[[ "${1:-}" == "-f" || "${1:-}" == "--foreground" ]] && FOREGROUND=1

die() { echo "reload: $*" >&2; exit 1; }

command -v quickshell >/dev/null || die "quickshell not found (run ./setup.sh)"
[[ -f "$DIR/shell.qml" ]] || die "no shell.qml in $DIR"

# 1. Refuse to restart into a broken config: validate shell.json first.
if [[ -f "$DIR/shell.json" ]]; then
  if command -v jq >/dev/null; then
    jq empty "$DIR/shell.json" 2>/dev/null || die "shell.json is not valid JSON — fix it first (jq empty shell.json)"
  elif command -v python3 >/dev/null; then
    python3 -m json.tool "$DIR/shell.json" >/dev/null 2>&1 || die "shell.json is not valid JSON"
  fi
fi

# 2. Stop the running instance for this config, fall back to pkill.
quickshell kill -p "$DIR" >/dev/null 2>&1 || pkill -x quickshell >/dev/null 2>&1
for _ in 1 2 3 4 5 6 7 8 9 10; do
  pgrep -x quickshell >/dev/null || break
  sleep 0.2
done
pgrep -x quickshell >/dev/null && pkill -9 -x quickshell

# 3. Start again.
mkdir -p "$(dirname "$LOG")"
if (( FOREGROUND )); then
  exec quickshell -p "$DIR"
fi

: >"$LOG"
setsid -f quickshell -p "$DIR" >"$LOG" 2>&1 </dev/null
sleep 1

if pgrep -x quickshell >/dev/null; then
  echo "quickshell restarted (log: $LOG)"
else
  echo "quickshell exited right after launch — last log lines:" >&2
  tail -n 25 "$LOG" >&2
  exit 1
fi
