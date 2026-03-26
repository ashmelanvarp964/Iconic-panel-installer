cat > /tmp/astra-fixed.sh << 'EOF'
#!/bin/bash

# ASTRA - Fixed Installer
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         ASTRA INSTALLER v2.0              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

# Get input
print_header
echo -e "${GREEN}This installer will setup Pterodactyl Panel + Wings + Blueprint${NC}"
echo ""

read -p "Enter your domain (e.g., panel.yourdomain.com): " DOMAIN
read -p "Enter your email for SSL: " EMAIL
read -sp "Enter database password: " DB_PASSWORD
echo ""
read -sp "Enter admin password: " ADMIN_PASSWORD
echo ""
echo ""

# Custom ports
read -p "Enter SSH port [22]: " SSH_PORT
SSH_PORT=${SSH_PORT:-22}
read -p "Enter Panel port [443]: " PANEL_PORT
PANEL_PORT=${PANEL_PORT:-443}
read -p "Enter Wings API port [8080]: " WINGS_API
WINGS_API=${WINGS_API:-8080}

echo ""
echo -e "${YELLOW}Starting installation...${NC}"
sleep 2

# Update system
echo -e "${CYAN}[1/12]${NC} Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo -e "${CYAN}[2/12]${NC} Installing Docker..."
curl -fsSL https://get.docker.com | sudo CHANNEL=stable bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Install MariaDB
echo -e "${CYAN}[3/12]${NC} Installing MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable --now mariadb

# Configure database
echo -e "${CYAN}[4/12]${NC} Configuring database..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS panel;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Install PHP
echo -e "${CYAN}[5/12]${NC} Installing PHP 8.1..."
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y php8.1 php8.1-{cli,common,curl,fpm,gd,intl,mysql,mbstring,xml,zip,bcmath,soap}

# Install Nginx
echo -e "${CYAN}[6/12]${NC} Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable --now nginx

# Install Composer
echo -e "${CYAN}[7/12]${NC} Installing Composer..."
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install Pterodactyl Panel
echo -e "${CYAN}[8/12]${NC} Installing Pterodactyl Panel..."
cd /var/www
sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
sudo tar -xzf panel.tar.gz
sudo mv panel-* pterodactyl
cd pterodactyl
sudo cp .env.example .env
sudo composer install --no-dev --optimize-autoloader
sudo php artisan key:generate --force

# Configure Panel
echo -e "${CYAN}[9/12]${NC} Configuring Panel..."
sudo php artisan p:environment:setup --author="$EMAIL" --url="https://$DOMAIN:$PANEL_PORT" --timezone=UTC
sudo php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=pterodactyl --password="$DB_PASSWORD"
sudo php artisan migrate --seed --force
sudo php artisan p:user:make --email="admin@$DOMAIN" --username=admin --name-first=Admin --password="$ADMIN_PASSWORD" --admin=1
sudo chown -R www-data:www-data /var/www/pterodactyl/*

# Install Wings
echo -e "${CYAN}[10/12]${NC} Installing Wings..."
sudo mkdir -p /etc/pterodactyl /var/lib/pterodactyl
sudo curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
sudo chmod +x /usr/local/bin/wings
sudo useradd -r -d /var/lib/pterodactyl -s /usr/sbin/nologin wings || true
sudo usermod -aG docker wings

# Configure Nginx
echo -e "${CYAN}[11/12]${NC} Configuring Nginx..."
sudo tee /etc/nginx/sites-available/pterodactyl << NGINX_EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name:$PANEL_PORT\$request_uri;
}

server {
    listen $PANEL_PORT ssl http2;
    server_name $DOMAIN;
    
    root /var/www/pterodactyl/public;
    index index.php;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
NGINX_EOF

sudo ln -sf /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Install SSL
echo -e "${CYAN}[12/12]${NC} Installing SSL certificate..."
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "$EMAIL" --redirect
sudo systemctl restart nginx

# Configure Firewall
echo -e "${CYAN}Configuring Firewall...${NC}"
sudo ufw --force enable
sudo ufw allow "$SSH_PORT"/tcp
sudo ufw allow 80/tcp
sudo ufw allow "$PANEL_PORT"/tcp
sudo ufw allow "$WINGS_API"/tcp
sudo ufw allow 2022/tcp
sudo ufw allow 25565/tcp
sudo ufw allow 25565/udp
sudo ufw reload

# Install Blueprint
echo -e "${CYAN}Installing Blueprint...${NC}"
cd /var/www/pterodactyl
sudo php artisan down
sudo curl -L https://github.com/BlueprintFramework/framework/raw/1.1.0/scripts/install.sh | sudo bash
sudo php artisan up

# Create Wings service
sudo tee /etc/systemd/system/wings.service << 'SERVICE_EOF'
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=wings
Group=docker
WorkingDirectory=/var/lib/pterodactyl
ExecStart=/usr/local/bin/wings
Restart=on-failure
RestartSec=10
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
SERVICE_EOF

sudo systemctl daemon-reload
sudo systemctl enable wings

# Save config
cat > ~/astra-info.txt << EOF
========================================
ASTRA Installation Complete!
========================================

Panel URL: https://$DOMAIN:$PANEL_PORT
Username: admin
Password: $ADMIN_PASSWORD

Ports:
- SSH: $SSH_PORT
- Panel: $PANEL_PORT
- Wings API: $WINGS_API
- Wings SFTP: 2022
- Minecraft: 25565

Next Steps:
1. Login to panel: https://$DOMAIN:$PANEL_PORT
2. Go to Admin → Nodes → Create New Node
3. Copy configuration URL
4. Run: sudo curl -o /etc/pterodactyl/config.yml <CONFIGURATION_URL>
5. Run: sudo systemctl start wings

========================================
EOF

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         INSTALLATION COMPLETE!             ║${NC}"
echo -e "${GREEN}║            WELCOME TO ASTRA                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Panel URL:${NC} https://$DOMAIN:$PANEL_PORT"
echo -e "${CYAN}Username:${NC} admin"
echo -e "${CYAN}Password:${NC} $ADMIN_PASSWORD"
echo ""
echo -e "${YELLOW}Info saved to: ~/astra-info.txt${NC}"
echo ""

EOF

bash /tmp/astra-fixed.sh
