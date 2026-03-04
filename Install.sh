#!/bin/bash

clear

logo() {
echo -e "\e[36m"
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
echo "      ⚡ ASHMEL PTERODACTYL INSTALLER ⚡"
echo -e "\e[0m"
}

menu() {

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) Install Panel"
echo "2) Install Wings"
echo "3) Install Panel + Wings (Auto)"
echo "4) Uninstall Panel"
echo "5) Uninstall Wings"
echo "6) Exit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
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

echo "Installing Dependencies..."

apt update -y
apt upgrade -y

apt install -y curl wget sudo software-properties-common apt-transport-https ca-certificates gnupg lsb-release

}

install_panel() {

dependencies

echo "Installing Panel..."

read -p "Enter Panel Domain (FQDN): " FQDN
read -p "Enter Admin Email: " EMAIL

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

echo ""
echo "Now follow the panel setup prompts"
php artisan p:environment:setup
php artisan p:environment:database
php artisan migrate --seed --force
php artisan p:user:make

chown -R www-data:www-data /var/www/pterodactyl

systemctl enable nginx
systemctl enable php8.2-fpm
systemctl enable redis-server

echo ""
echo "✅ PANEL INSTALLED"
echo "Domain: $FQDN"

sleep 3
main

}

install_wings() {

echo "Installing Wings..."

curl -s https://pterodactyl-installer.se | bash

echo "✅ Wings Installed"

sleep 2
main

}

install_both() {

install_panel
install_wings

}

uninstall_panel() {

echo "Removing Panel..."

systemctl stop nginx
systemctl stop php8.2-fpm

rm -rf /var/www/pterodactyl

apt remove nginx mariadb-server redis-server php8.2* -y

echo "Panel removed"

sleep 2
main

}

uninstall_wings() {

echo "Removing Wings..."

systemctl stop wings

rm -rf /etc/pterodactyl
rm -rf /usr/local/bin/wings

echo "Wings removed"

sleep 2
main

}

main() {
clear
logo
menu
}

main
