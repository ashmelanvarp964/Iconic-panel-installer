```bash
#!/bin/bash

clear

# ===== COLORS =====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ===== ANIMATED LOGO =====
logo() {

echo -e "${CYAN}"
sleep 0.05
echo " █████╗ ███████╗██╗  ██╗███╗   ███╗███████╗██╗     "
sleep 0.05
echo "██╔══██╗██╔════╝██║  ██║████╗ ████║██╔════╝██║     "
sleep 0.05
echo "███████║███████╗███████║██╔████╔██║█████╗  ██║     "
sleep 0.05
echo "██╔══██║╚════██║██╔══██║██║╚██╔╝██║██╔══╝  ██║     "
sleep 0.05
echo "██║  ██║███████║██║  ██║██║ ╚═╝ ██║███████╗███████╗"
sleep 0.05
echo "╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝"
echo ""
echo -e "${MAGENTA}        ⚡ ASHMEL PREMIUM INSTALLER ⚡${NC}"
echo ""
}

# ===== LOADING BAR =====
loading() {

echo -ne "${YELLOW}Installing"
for i in {1..6}; do
echo -ne "."
sleep 0.4
done
echo -e "${NC}"
}

# ===== MENU =====
menu() {

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}[1]${NC} Install Panel"
echo -e "${GREEN}[2]${NC} Install Wings"
echo -e "${GREEN}[3]${NC} Install Panel + Wings"
echo -e "${RED}[4]${NC} Uninstall Panel"
echo -e "${RED}[5]${NC} Uninstall Wings"
echo -e "${CYAN}[6]${NC} Exit"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "Select option: " option

case $option in
1) install_panel ;;
2) install_wings ;;
3) install_all ;;
4) uninstall_panel ;;
5) uninstall_wings ;;
6) exit ;;
*) echo "Invalid option"; sleep 2; main ;;
esac

}

# ===== DEPENDENCIES =====
deps() {

loading

apt update -y
apt install -y curl wget tar unzip sudo software-properties-common apt-transport-https ca-certificates gnupg

}

# ===== PANEL INSTALL =====
install_panel() {

deps

echo -e "${CYAN}Panel Setup${NC}"

read -p "Panel Domain (FQDN): " DOMAIN
read -p "Admin Email: " EMAIL
read -s -p "Admin Password: " PASSWORD
echo ""

loading

add-apt-repository ppa:ondrej/php -y
apt update

apt install -y php8.2 php8.2-cli php8.2-gd php8.2-mysql php8.2-mbstring php8.2-bcmath php8.2-xml php8.2-fpm php8.2-curl php8.2-zip

apt install -y nginx mariadb-server redis-server

curl -sL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz

tar -xzvf panel.tar.gz

chmod -R 755 storage/* bootstrap/cache/

cp .env.example .env

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

composer install --no-dev --optimize-autoloader

php artisan key:generate --force

php artisan migrate --seed --force

php artisan p:user:make <<EOF
Ashmel
Admin
admin
$EMAIL
$PASSWORD
yes
EOF

chown -R www-data:www-data /var/www/pterodactyl

systemctl enable nginx
systemctl enable redis-server
systemctl enable php8.2-fpm

echo ""
echo -e "${GREEN}✔ Panel Installed Successfully${NC}"
echo "Domain: $DOMAIN"

sleep 3
main

}

# ===== WINGS INSTALL =====
install_wings() {

loading

curl -s https://pterodactyl-installer.se | bash

echo -e "${GREEN}✔ Wings Installed${NC}"

sleep 3
main

}

# ===== INSTALL BOTH =====
install_all() {

install_panel
install_wings

}

# ===== REMOVE PANEL =====
uninstall_panel() {

echo -e "${RED}Removing Panel...${NC}"

systemctl stop nginx
rm -rf /var/www/pterodactyl

apt remove nginx mariadb-server redis-server php8.2* -y

echo -e "${GREEN}Panel Removed${NC}"

sleep 3
main

}

# ===== REMOVE WINGS =====
uninstall_wings() {

echo -e "${RED}Removing Wings...${NC}"

systemctl stop wings
rm -rf /etc/pterodactyl
rm -rf /usr/local/bin/wings

echo -e "${GREEN}Wings Removed${NC}"

sleep 3
main

}

# ===== MAIN =====
main() {

clear
logo
menu

}

main
```
