#!/usr/bin/env bash
set -euo pipefail

# ===== Colors =====
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

# ===== UI Functions =====
line() { echo -e "\033[1;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"; }
step() { echo -e "${BLUE}➜ $1${RESET}"; }
ok() { echo -e "${GREEN}✔ $1${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $1${RESET}"; }
error() { echo -e "${RED}❌ $1${RESET}"; }

# ===== Banner =====
banner() {
  clear
  echo -e "${BLUE}"
  cat <<'BANNER'

 ██╗ ██████╗ ██████╗ ███╗   ██╗██╗ ██████╗
 ██║██╔════╝██╔═══██╗████╗  ██║██║██╔════╝
 ██║██║     ██║   ██║██╔██╗ ██║██║██║
 ██║██║     ██║   ██║██║╚██╗██║██║██║
 ██║╚██████╗╚██████╔╝██║ ╚████║██║╚██████╗
 ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚═════╝

        ICONIC VPS INSTALLER

BANNER
  echo -e "${RESET}"
}

# ===== Confirm =====
confirm() {
  read -rp "$(echo -e "${YELLOW}$1 (y/n): ${RESET}")" ans
  [[ "${ans}" =~ ^[Yy]$ ]]
}

# ===== Main Menu =====
banner
echo -e "${YELLOW}1) Vm Tool${RESET}"
echo -e "${CYAN}2) Install Cloudflared${RESET}"
echo -e "${YELLOW}3) Configure Pterodactyl Wings${RESET}"
echo -e "${GREEN}4) Install Pterodactyl Panel${RESET}"
echo -e "${RED}0) Exit${RESET}"
echo ""

read -rp "Enter choice (1-4): " CHOICE
echo ""

case "$CHOICE" in

1)
confirm "Run Vm Tool?" || exit 0
bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/main/srv/vm/vps.sh)
;;

2)
confirm "Install Cloudflared?" || exit 0
sudo apt update
sudo apt install -y cloudflared
ok "Cloudflared installed"
;;

3)
confirm "Configure Wings?" || exit 0
bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/main/srv/wings/auto1.sh)
;;

4)
clear
echo -e "${CYAN}"

cat << "EOF"

██╗ ██████╗ ██████╗ ███╗   ██╗██╗ ██████╗
██║██╔════╝██╔═══██╗████╗  ██║██║██╔════╝
██║██║     ██║   ██║██╔██╗ ██║██║██║
██║██║     ██║   ██║██║╚██╗██║██║██║
██║╚██████╗╚██████╔╝██║ ╚████║██║╚██████╗
╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚═════╝

        PTERODACTYL PANEL INSTALLER

EOF

echo -e "${RESET}"
line
echo -e "${GREEN}⚡ Fast • Stable • Production Ready${RESET}"
line

read -p "🌐 Enter domain (panel.example.com): " DOMAIN

step "Starting Pterodactyl Panel installation..."
sleep 2

ok "Installer template working ✔"

;;

0)
echo "Exiting ICONIC Installer."
exit 0
;;

*)
echo -e "${RED}Invalid choice${RESET}"
exit 1
;;

esac
