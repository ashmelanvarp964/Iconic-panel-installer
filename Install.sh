```bash
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

dependencies() {

echo -e "${CYAN}Installing dependencies...${NC}"

apt update -y
apt upgrade -y

apt install -y curl wget tar unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

}

install_panel() {

dependencies

echo -e "${CYAN}Panel Setup${NC}"

read -p "Admin Email: " ADMIN_EMAIL
read -s -p "Admin Password: " ADMIN_PASS
echo
read -p "Panel Domain (FQDN): " FQDN

echo -e "${GREEN}Installing panel packages...${NC}"

add-apt-repository ppa:ondrej/php -y
apt update

apt install -y php8.2 php8.2-cli php8.2-gd php8.2-mysql php8.2-mbstring php8.2-bcmath php8.2-xml php8.2-fpm php8.2-curl php8.2-zip

apt install -y mariadb-server nginx redis-server

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

echo -e "${GREEN}Setting up database & environment...${NC}"

php artisan p:environment:setup
php artisan p:environment:database
php artisan migrate --seed --force

echo -e "${GREEN}Creating admin account...${NC}"

php artisan p:user:make <<EOF
Ashmel
Admin
admin
$ADMIN_EMAIL
$ADMIN_PASS
yes
EOF

chown -R www-data:www-data /var/www/pterodactyl

systemctl enable nginx
systemctl enable php8.2-fpm
systemctl enable redis-server

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

sleep 3
main

}

install_both() {

install_panel
install_wings

}

uninstall_panel() {

echo -e "${RED}Removing Panel...${NC}"

systemctl stop nginx
systemctl stop php8.2-fpm

rm -rf /var/www/pterodactyl

apt remove nginx mariadb-server redis-server php8.2* -y

echo -e "${GREEN}Panel Removed${NC}"

sleep 3
main

}

uninstall_wings() {

echo -e "${RED}Removing Wings...${NC}"

systemctl stop wings

rm -rf /etc/pterodactyl
rm -rf /usr/local/bin/wings

echo -e "${GREEN}Wings Removed${NC}"

sleep 3
main

}

main() {
clear
logo
menu
}

main
```
