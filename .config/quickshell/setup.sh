#!/usr/bin/env bash
# setup.sh — dependency check (and optional install) for this Quickshell config. Arch Linux.
#   ./setup.sh             check only
#   ./setup.sh --install   check, then install what is missing (pacman, then paru/yay for AUR)

set -u
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL=0
[[ "${1:-}" == "--install" ]] && INSTALL=1

ok()   { printf '  \e[32m✔\e[0m %s\n' "$*"; }
bad()  { printf '  \e[31m✘\e[0m %s\n' "$*"; }
warn() { printf '  \e[33m!\e[0m %s\n' "$*"; }

# command -> package
declare -A REQUIRED=(
  [quickshell]=quickshell
  [niri]=niri
  [nmcli]=networkmanager
  [brightnessctl]=brightnessctl
  [makoctl]=mako
  [gtklock]=gtklock
  [wpctl]=wireplumber
  [bluetoothctl]=bluez-utils
)
declare -A OPTIONAL=(
  [jq]=jq
  [wlsunset]=wlsunset
  [playerctl]=playerctl
  [cava]=cava
)

missing=()

echo "Required tools"
for cmd in "${!REQUIRED[@]}"; do
  if command -v "$cmd" >/dev/null; then ok "$cmd"; else bad "$cmd  (package: ${REQUIRED[$cmd]})"; missing+=("${REQUIRED[$cmd]}"); fi
done

echo "Optional tools"
for cmd in "${!OPTIONAL[@]}"; do
  if command -v "$cmd" >/dev/null; then ok "$cmd"; else warn "$cmd  (package: ${OPTIONAL[$cmd]})"; fi
done

echo "Services"
if systemctl is-active --quiet upower 2>/dev/null; then ok "upower (battery widget)"; else warn "upower is not running — battery widget will stay hidden (systemctl enable --now upower)"; fi
if systemctl is-active --quiet NetworkManager 2>/dev/null; then ok "NetworkManager"; else warn "NetworkManager is not running"; fi
if pacman -Qi bluez >/dev/null 2>&1; then ok "bluez (daemon)"; else bad "bluez  (package: bluez)"; missing+=(bluez); fi
if systemctl is-active --quiet bluetooth 2>/dev/null; then ok "bluetooth.service"; else warn "bluetooth.service is not running (systemctl enable --now bluetooth)"; fi

echo "Fonts"
if fc-list 2>/dev/null | grep -qi quantico; then ok "Quantico"; else warn "Quantico not found — install it, or change appearance.fontFamily in shell.json"; fi
if fc-list 2>/dev/null | grep -qi "nerd"; then ok "a Nerd Font (icon glyphs)"; else warn "no Nerd Font found — icons will render as boxes (pacman -S ttf-nerd-fonts-symbols)"; fi

echo "Config"
if [[ -f "$DIR/shell.json" ]]; then
  if command -v jq >/dev/null && ! jq empty "$DIR/shell.json" 2>/dev/null; then bad "shell.json is not valid JSON"; else ok "shell.json"; fi
else
  warn "shell.json missing — it will be generated from defaults on first launch"
fi
[[ -f "$DIR/shell.qml" ]] && ok "shell.qml" || bad "shell.qml missing"
chmod +x "$DIR/setup.sh" "$DIR/reload-quickshell.sh" 2>/dev/null
case "$DIR" in
  "$HOME/.config/quickshell"*) ok "located under ~/.config/quickshell" ;;
  *) warn "not under ~/.config/quickshell — stow/symlink it there, or run: quickshell -p $DIR" ;;
esac

if (( ${#missing[@]} == 0 )); then
  echo; echo "All required dependencies present."; exit 0
fi

echo; echo "Missing packages: ${missing[*]}"
if (( ! INSTALL )); then
  echo "Re-run with --install to install them."; exit 1
fi

official=(); aur=()
for p in "${missing[@]}"; do
  if pacman -Si "$p" >/dev/null 2>&1; then official+=("$p"); else aur+=("$p"); fi
done
if (( ${#official[@]} )); then sudo pacman -S --needed "${official[@]}"; fi
if (( ${#aur[@]} )); then
  helper="$(command -v paru || command -v yay || true)"
  if [[ -n "$helper" ]]; then "$helper" -S --needed "${aur[@]}"; else warn "not in the official repos and no AUR helper found: ${aur[*]}"; fi
fi
