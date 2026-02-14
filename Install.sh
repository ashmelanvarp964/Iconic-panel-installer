#!/usr/bin/env bash
set -euo pipefail

# ===== Colors =====
BLUE='\033[1;34m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; RESET='\033[0m'

# ===== UI =====
line() { echo -e "\033[1;90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"; }
step() { echo -e "${BLUE}➜ $1${RESET}"; }
ok() { echo -e "${GREEN}✔ $1${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $1${RESET}"; }

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

confirm() {
read -rp "$(echo -e "${YELLOW}$1 (y/n): ${RESET}")" ans
[[ "$ans" =~ ^[Yy]$ ]]
}

# ===== Menu =====
banner
echo -e "${YELLOW}1) Vm Tool${RESET}"
echo -e "${CYAN}2) Install Cloudflared${RESET}"
echo -e "${YELLOW}3) Configure Pterodactyl Wings${RESET}"
echo -e "${GREEN}4) Install Pterodactyl Panel${RESET}"
echo -e "${RED}0) Exit${RESET}"
echo ""

read -rp "Enter choice: " CHOICE
echo ""

case "$CHOICE" in

# ===== VM TOOL =====
1)
confirm "Run Vm Tool?" || exit 0
bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/main/srv/vm/vps.sh)
;;

# ===== CLOUDFLARED =====
2)
confirm "Install Cloudflared?" || exit 0
sudo apt update
sudo apt install -y cloudflared
ok "Cloudflared installed"
;;

# ===== WINGS =====
3)
confirm "Configure Wings?" || exit 0
bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/main/srv/wings/auto1.sh)
;;

# ===== PANEL INSTALL =====
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

# ===== SERVER PREP + NGINX FIX =====
step "Preparing server (auto fix)..."

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip nginx software-properties-common \
ca-certificates apt-transport-https lsb-release

sudo systemctl stop apache2 2>/dev/null || true
sudo apt remove apache2 -y 2>/dev/null || true

curl -fsSL https://get.docker.com | bash
sudo systemctl enable docker
sudo systemctl start docker

sudo systemctl enable nginx
sudo systemctl start nginx

sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 8443
sudo ufw allow OpenSSH
sudo ufw --force enable

sudo fuser -k 80/tcp 2>/dev/null || true
sudo fuser -k 443/tcp 2>/dev/null || true

sudo nginx -t
sudo systemctl restart nginx

ok "Server ready + nginx fixed"

line

read -p "🌐 Enter domain (panel.example.com): " DOMAIN

step "Starting Pterodactyl Panel installation..."

# (your panel install commands continue here...)

ok "Installer template ready (add panel commands below)"

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
