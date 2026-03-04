#!/bin/bash

clear

# COLORS
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
NC='\033[0m'

logo() {

echo -e "${CYAN}"
echo " █████╗ ███████╗██╗  ██╗███╗   ███╗███████╗██╗     "
sleep 0.1
echo "██╔══██╗██╔════╝██║  ██║████╗ ████║██╔════╝██║     "
sleep 0.1
echo "███████║███████╗███████║██╔████╔██║█████╗  ██║     "
sleep 0.1
echo "██╔══██║╚════██║██╔══██║██║╚██╔╝██║██╔══╝  ██║     "
sleep 0.1
echo "██║  ██║███████║██║  ██║██║ ╚═╝ ██║███████╗███████╗"
sleep 0.1
echo "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝"
echo ""
echo -e "${GREEN}        ⚡ ASHMEL PTERODACTYL INSTALLER ⚡${NC}"
echo ""
}

menu() {

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}1)${NC} Install Panel"
echo -e "${GREEN}2)${NC} Install Wings"
echo -e "${GREEN}3)${NC} Install Panel + Wings"
echo -e "${RED}4)${NC} Uninstall Panel"
echo -e "${RED}5)${NC} Uninstall Wings"
echo -e "${BLUE}6)${NC} Exit"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Select option: " option

case $option in
1) install_panel ;;
2) install_wings ;;
3) install_both ;;
4) uninstall_panel ;;
5) uninstall_wings ;;
6) exit ;;
*) echo "Invalid option"; sleep 2; main ;;
esac

}

install_panel() {

echo -e "${CYAN}Panel Setup${NC}"

read -p "Admin Email: " ADMIN_EMAIL
read -s -p "Admin Password: " ADMIN_PASS
echo ""

read -p "Panel Domain (FQDN): " FQDN

echo -e "${GREEN}Installing dependencies...${NC}"

apt update -y
apt install -y curl wget nginx mariadb-server redis-server

mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz

tar -xzvf panel.tar.gz

echo ""
echo -e "${GREEN}Creating Admin Account...${NC}"

php artisan p:user:make <<EOF
$ADMIN_EMAIL
admin
admin
admin
$ADMIN_PASS
yes
EOF

echo ""
echo -e "${GREEN}Panel Installed Successfully${NC}"
echo "Domain: $FQDN"

sleep 3
main

}

install_wings() {

echo -e "${CYAN}Installing Wings...${NC}"

curl -s https://pterodactyl-installer.se | bash

echo -e "${GREEN}Wings Installed${NC}"

sleep 2
main

}

install_both() {

install_panel
install_wings

}

uninstall_panel() {

echo -e "${RED}Removing Panel...${NC}"

rm -rf /var/www/pterodactyl
apt remove nginx mariadb-server redis-server -y

echo -e "${GREEN}Panel Removed${NC}"

sleep 2
main

}

uninstall_wings() {

echo -e "${RED}Removing Wings...${NC}"

systemctl stop wings
rm -rf /etc/pterodactyl

echo -e "${GREEN}Wings Removed${NC}"

sleep 2
main

}

main() {
clear
logo
menu
}

main
