#!/usr/bin/env base
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

# ===== Loading bar animation =====
progress_bar() {
  local duration=$1
  local width=30
  for ((i=0;i<duration;i++)); do
    local filled=$(( (i*width)/duration ))
    local empty=$(( width-filled ))
    printf "\r["
    printf "%*s" "$filled" '' | tr ' ' '#'
    printf "%*s" "$empty" ''
    printf "] %3d%%" $(( i*100/duration ))
    sleep 0.03
  done
  printf "\r["
  printf "%*s" "$width" '' | tr ' ' '#'
  printf "] 100%%\n"
}

# ===== Banner =====
banner() {
  clear
  echo -e "${BLUE}"
  cat <<'BANNER'

echo "
  _____ _____ ___  _   _ ___  _____
 |_   _|_   _/ _ \| \ | |_ _|/ ____|
   | |   | || | | |  \| || || |
   | |   | || | | | . \` || || |
  _| |_ _| || |_| | |\  || || |____
 |_____|_____\___/|_| \_|___|\_____|

        ICONIC VPS INSTALLER
"

                     
B# ===== Banner =====
banner() {
  clear
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

}
BANNER
  echo -e "${CYAN}       ICONIC  Installer ⚡${RESET}"
  echo ""
}

# ===== Confirm function =====
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

# ===== Handle choices =====
case "$CHOICE" in
  # ===== Option 1: Vm Tool =====
  1)
    confirm "Run Vm Tool?" || exit 0
    echo -e "${CYAN}Running Vm Tool...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/refs/heads/main/srv/vm/vps.sh)
    ;;
  
  # ===== Option 2: Cloudflared installer =====
  2)
    confirm "Install Cloudflared (official method)?" || exit 0
    echo -e "${CYAN}Installing Cloudflared...${RESET}"
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    sudo curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
    echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
      sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y cloudflared >/dev/null 2>&1 && echo -e "${GREEN}✅ Cloudflared installed successfully!${RESET}" || echo -e "${RED}❌ Cloudflared installation failed.${RESET}"
    
    echo -e "\n${YELLOW}📋 Manual Tunnel Setup Required:${RESET}"
    echo -e "1. Go to Cloudflare Dashboard → Zero Trust → Tunnels"
    echo -e "2. Create a new tunnel"
    echo -e "3. Copy the installation command"
    echo -e "4. Run it on this server"
    echo -e "5. Configure the tunnel to point to your service"
    echo -e "\n${CYAN}Example service URL: http://localhost:PORT${RESET}"
    ;;
  
  # ===== Option 3: Configure Pterodactyl Wings =====
  3)
    confirm "Configure Pterodactyl Wings?" || exit 0
    echo -e "${CYAN}Configuring Pterodactyl Wings...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/StriderCraft315/Codes/refs/heads/main/srv/wings/auto1.sh)
    ;;
  
  # ===== Option 4: Install Pterodactyl Panel =====
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

EOF
    echo -e "${RESET}"
    line
    echo -e "${GREEN}⚡ Fast • Stable • Production Ready${RESET}"
    echo -e "${BLUE}🧠 AstraCloud  Hosting — 2026 Installer${RESET}"
    line
    echo ""
    
    # Get domain
    read -p "🌐 Enter domain (panel.example.com): " DOMAIN
    
    # Ask for deployment type
    echo ""
    echo -e "${YELLOW}🚀 How will you expose your panel?${RESET}"
    echo "   [1] Cloudflare Tunnel (Proxy)"
    echo "   [2] Direct A Record (Public IP)"
    echo ""
    read -p "Select option (1 or 2): " DEPLOY_TYPE
    
    case $DEPLOY_TYPE in
      1)
        HTTP_PORT=8000
        HTTPS_PORT=8443
        DEPLOY_MODE="Cloudflare Tunnel"
        echo -e "${BLUE}→ Using Cloudflare Tunnel mode (Ports: 8000/8443)${RESET}"
        
        # Ask about Cloudflared installation
        echo ""
        if confirm "Do you want to install Cloudflared now?"; then
          step "Installing Cloudflared..."
          sudo mkdir -p --mode=0755 /usr/share/keyrings
          sudo curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
          echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | \
            sudo tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
          sudo apt-get update -qq
          sudo apt-get install -y cloudflared >/dev/null 2>&1 && ok "Cloudflared installed" || error "Cloudflared installation failed"
          
          echo ""
          echo -e "${YELLOW}📋 Manual Tunnel Setup Required:${RESET}"
          echo -e "1. Go to Cloudflare Dashboard → Zero Trust → Tunnels"
          echo -e "2. Create a new tunnel"
          echo -e "3. Copy the installation command"
          echo -e "4. Run it on this server"
          echo -e "5. Add this service to your tunnel:"
          echo -e "   ${CYAN}Service: https://localhost:${HTTPS_PORT}${RESET}"
          echo -e "   ${CYAN}Hostname: ${DOMAIN}${RESET}"
          echo ""
          read -p "Press Enter to continue with panel installation..."
        fi
        ;;
      2)
        HTTP_PORT=80
        HTTPS_PORT=443
        DEPLOY_MODE="A Record"
        echo -e "${BLUE}→ Using A Record mode (Ports: 80/443)${RESET}"
        
        # Check if ports 80/443 are available
        if command -v netstat &> /dev/null; then
          if netstat -tuln | grep -q ":80 "; then
            warn "Port 80 is already in use! You may need to stop other services (Apache, etc.)"
          fi
          if netstat -tuln | grep -q ":443 "; then
            warn "Port 443 is already in use! You may need to stop other services (Apache, etc.)"
          fi
        fi
        
        # Get public IP for DNS guidance
        PUBLIC_IP=$(curl -4 -s ifconfig.co || echo "YOUR_SERVER_IP")
        echo -e "${CYAN}→ Create DNS A record: ${DOMAIN} → ${PUBLIC_IP}${RESET}"
        ;;
      *)
        echo -e "${RED}❌ Invalid option, defaulting to Cloudflare Tunnel mode${RESET}"
        HTTP_PORT=8000
        HTTPS_PORT=8443
        DEPLOY_MODE="Cloudflare Tunnel"
        ;;
    esac
    
    line
    step "Starting Pterodactyl Panel installation..."
    echo ""
    
    # --- Dependencies ---
    apt update && apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release
    
    # Detect OS
    OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    
    if [[ "$OS" == "ubuntu" ]]; then
      echo "✅ Detected Ubuntu. Adding PPA for PHP..."
      apt install -y software-properties-common
      LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
    elif [[ "$OS" == "debian" ]]; then
      echo "✅ Detected Debian. Skipping PPA and adding PHP repo manually..."
      curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
      echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list
    fi
    
    # Add Redis repo
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    
    apt update
    
    # --- Install PHP + extensions ---
    apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} mariadb-server nginx redis-server
    
    # --- Install Composer ---
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
    
    # --- Download Pterodactyl Panel ---
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    
    # --- MariaDB Setup ---
    DB_NAME=panel
    DB_USER=pterodactyl
    DB_PASS=$(openssl rand -base64 32)
    echo "✅ Generating secure database password..."
    mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';"
    mariadb -e "CREATE DATABASE ${DB_NAME};"
    mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;"
    mariadb -e "FLUSH PRIVILEGES;"
    
    # --- .env Setup ---
    if [ ! -f ".env.example" ]; then
      curl -Lo .env.example https://raw.githubusercontent.com/pterodactyl/panel/develop/.env.example
    fi
    cp .env.example .env
    sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
    if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
      echo "APP_ENVIRONMENT_ONLY=false" >> .env
    fi
    
    # --- Install PHP dependencies ---
    echo "✅ Installing PHP dependencies..."
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    
    # --- Generate Application Key ---
    echo "✅ Generating application key..."
    php artisan key:generate --force
    
    # --- Run Migrations ---
    php artisan migrate --seed --force
    
    # --- Permissions ---
    chown -R www-data:www-data /var/www/pterodactyl/*
    apt install -y cron
    systemctl enable --now cron
    (crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
    
    # --- Nginx Setup ---
    mkdir -p /etc/certs/panel
    cd /etc/certs/panel
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=NA/ST=NA/L=NA/O=NA/CN=Generic SSL Certificate" \
    -keyout privkey.pem -out fullchain.pem
    
    # Generate Nginx config based on deployment type
    if [[ "$DEPLOY_TYPE" == "2" ]]; then
      # A Record mode - standard 80/443
      tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    else
      # Cloudflare Tunnel mode - custom ports
      tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null << EOF
server {
    listen ${HTTP_PORT};
    server_name ${DOMAIN};
    return 301 https://\$server_name:${HTTPS_PORT}\$request_uri;
}

server {
    listen ${HTTPS_PORT} ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    fi
    
    ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf || true
    nginx -t && systemctl restart nginx
    ok "Nginx configured for ${DEPLOY_MODE}"
    
    # --- Queue Worker ---
    tee /etc/systemd/system/pteroq.service > /dev/null << 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable --now redis-server
    systemctl enable --now pteroq.service
    ok "Queue running"
    
    clear
    step "Create admin user"
    # --- Admin User ---
    cd /var/www/pterodactyl
    sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
    php artisan p:user:make
    
    # ---------------- DONE ----------------
    line
    echo -e "${GREEN}🎉 PTERODACTYL PANEL INSTALLED SUCCESSFULLY${RESET}"
    line
    echo -e "${CYAN}🌐 Panel URL    : ${YELLOW}https://${DOMAIN}${RESET}"
    echo -e "${CYAN}🗄 DB User      : ${YELLOW}${DB_USER}${RESET}"
    echo -e "${CYAN}🔑 DB Password  : ${YELLOW}${DB_PASS}${RESET}"
    echo -e "${CYAN}🚀 Deployment   : ${YELLOW}${DEPLOY_MODE}${RESET}"
    echo -e "${CYAN}🔌 HTTP Port    : ${YELLOW}${HTTP_PORT}${RESET}"
    echo -e "${CYAN}🔌 HTTPS Port   : ${YELLOW}${HTTPS_PORT}${RESET}"
    line
    
    if [[ "$DEPLOY_TYPE" == "1" ]]; then
      echo -e "${YELLOW}📋 Cloudflare Tunnel Next Steps:${RESET}"
      echo -e "1. Go to ${CYAN}https://dash.cloudflare.com/${RESET}"
      echo -e "2. Zero Trust → Networks → Tunnels"
      echo -e "3. Create tunnel → Choose 'Cloudflared'"
      echo -e "4. Name your tunnel → Save"
      echo -e "5. Copy the installation command"
      echo -e "6. Run it on this server"
      echo -e "7. Add Public Hostname:"
      echo -e "   - Subdomain: ${CYAN}panel${RESET} (or your choice)"
      echo -e "   - Domain: ${CYAN}${DOMAIN#*.}${RESET}"
      echo -e "   - URL: ${CYAN}https://localhost:${HTTPS_PORT}${RESET}"
      echo -e "   - Save tunnel"
    elif [[ "$DEPLOY_TYPE" == "2" ]]; then
      echo -e "${YELLOW}📋 DNS Configuration:${RESET}"
      echo -e "Create an A record in your DNS:"
      echo -e "${CYAN}Type: A${RESET}"
      echo -e "${CYAN}Name: ${DOMAIN%%.*}${RESET}"
      echo -e "${CYAN}Value: ${PUBLIC_IP}${RESET}"
      echo -e "${CYAN}TTL: 300${RESET}"
    fi
    
    echo ""
    echo -e "${BLUE}🚀 Panel is now running! Access it at https://${DOMAIN}${RESET}"
    line
    ;;
  
  # ===== Option 0: Exit =====
  0)
    echo -e "${CYAN}Exiting Zycron Installer. Goodbye! ⚡${RESET}"
    exit 0
    ;;
  
  # ===== Invalid choice =====
  *)
    echo -e "${RED}Invalid choice. Exiting.${RESET}"
    exit 1
    ;;
esac
