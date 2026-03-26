#!/bin/bash

# ============================================
# ASTRA - Pterodactyl Panel + Wings + Blueprint
# Complete Installation Script with Animation
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Animation variables
SPINNER="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
COLORS=($CYAN $BLUE $MAGENTA $GREEN $YELLOW)
ANIMATION_DELAY=0.1

# Clear screen
clear

# Function for animated spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function for typing animation
type_animation() {
    local text="$1"
    local delay=${2:-0.03}
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
    echo
}

# Function for progress bar
progress_bar() {
    local duration=$1
    local width=50
    local percent=0
    local elapsed=0
    
    echo -n "["
    for ((i=0; i<$width; i++)); do
        echo -n " "
    done
    echo -n "] 0%"
    
    while [ $elapsed -lt $duration ]; do
        sleep 0.1
        elapsed=$((elapsed + 1))
        percent=$((elapsed * 100 / duration))
        filled=$((percent * width / 100))
        
        echo -ne "\r["
        for ((i=0; i<$filled; i++)); do
            echo -ne "${GREEN}▓${NC}"
        done
        for ((i=$filled; i<$width; i++)); do
            echo -ne " "
        done
        echo -ne "] ${percent}%"
    done
    echo ""
}

# Animated ASTRA Logo
animated_astra_logo() {
    clear
    
    # Frame 1
    echo -e "${CYAN}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ "
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    sleep 0.5
    
    clear
    # Frame 2
    echo -e "${BLUE}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ "
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    sleep 0.5
    
    clear
    # Frame 3
    echo -e "${MAGENTA}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ "
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"
    sleep 0.5
    
    clear
    # Final frame with gradient effect
    echo -e "${CYAN}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ "
    echo -e "${BLUE}   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗"
    echo -e "${MAGENTA}   ███████║███████╗   ██║   ██████╔╝███████║"
    echo -e "${GREEN}   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║"
    echo -e "${YELLOW}   ██║  ██║███████║   ██║   ██║  ██║██║  ██║"
    echo -e "${RED}   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝${NC}"
    echo ""
    
    # Typing animation for tagline
    type_animation "    ═══════════════════════════════════════════════" 0.02
    type_animation "     Pterodactyl Panel + Wings + Blueprint Installer" 0.02
    type_animation "    ═══════════════════════════════════════════════" 0.02
    echo ""
    sleep 1
}

# Function for pulsing text
pulse_text() {
    local text="$1"
    local duration=$2
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        echo -ne "\r${GREEN}▶${NC} ${text} ${CYAN}✦${NC}    "
        sleep 0.3
        echo -ne "\r${YELLOW}▶${NC} ${text} ${MAGENTA}✦${NC}    "
        sleep 0.3
        echo -ne "\r${CYAN}▶${NC} ${text} ${GREEN}✦${NC}    "
        sleep 0.3
    done
    echo -e "\r${GREEN}✓${NC} ${text} ${GREEN}Complete!${NC}    "
}

# Animated menu
animated_menu() {
    clear
    animated_astra_logo
    
    echo -e "${WHITE}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}${BOLD}║     SELECT INSTALLATION OPTIONS           ║${NC}"
    echo -e "${WHITE}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Animated option display
    sleep 0.5
    echo -e "${CYAN}  ┌──────────────────────────────────────────┐${NC}"
    for i in {1..5}; do
        echo -ne "\r${CYAN}  │${NC} "
        case $i in
            1) echo -ne "${GREEN}●${NC} Full Installation (Panel + Wings + Blueprint)";;
            2) echo -ne "${YELLOW}●${NC} Panel Only Installation";;
            3) echo -ne "${BLUE}●${NC} Wings Only Installation";;
            4) echo -ne "${MAGENTA}●${NC} Configure Firewall Only";;
            5) echo -ne "${RED}●${NC} Exit";;
        esac
        echo -e "                        ${CYAN}│${NC}"
        sleep 0.2
    done
    echo -e "${CYAN}  └──────────────────────────────────────────┘${NC}"
    echo ""
    
    read -p "$(echo -e ${GREEN}➜${NC} Enter your choice [1-5]: " choice
    echo $choice
}

# Animated installation function
animated_installation() {
    local step=$1
    local total=$2
    local description=$3
    
    echo -ne "\r${CYAN}[${step}/${total}]${NC} ${description} "
    
    # Spinner animation
    local pid=$!
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r${CYAN}[${step}/${total}]${NC} ${description} ${spin:$i:1}"
        sleep 0.1
    done
    printf "\r${GREEN}[${step}/${total}]${NC} ${description} ${GREEN}✓${NC}\n"
}

# Function to get custom port with animation
get_custom_port_animated() {
    local prompt="$1"
    local default="$2"
    local port=""
    
    echo -ne "${CYAN}➜${NC} $prompt ${YELLOW}[$default]${NC} "
    
    # Animated cursor
    for i in {1..3}; do
        echo -ne "${BLUE}▌${NC}"
        sleep 0.1
    done
    echo -ne " "
    
    read port
    if [ -z "$port" ]; then
        port="$default"
    fi
    
    # Validate port
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}✗ Invalid port! Using default: $default${NC}"
        port="$default"
    else
        echo -e "${GREEN}✓ Port $port selected${NC}"
    fi
    
    echo "$port"
}

# Configure ports with animation
configure_ports_animated() {
    clear
    animated_astra_logo
    
    echo -e "${WHITE}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}${BOLD}║         CUSTOM PORT CONFIGURATION         ║${NC}"
    echo -e "${WHITE}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    pulse_text "Loading port configuration wizard" 2
    
    # Basic ports
    SSH_PORT=$(get_custom_port_animated "Enter SSH port" "22")
    HTTP_PORT=$(get_custom_port_animated "Enter HTTP port" "80")
    HTTPS_PORT=$(get_custom_port_animated "Enter HTTPS port" "443")
    PANEL_PORT=$(get_custom_port_animated "Enter Panel web port" "$HTTPS_PORT")
    WINGS_API_PORT=$(get_custom_port_animated "Enter Wings API port" "8080")
    WINGS_SFTP_PORT=$(get_custom_port_animated "Enter Wings SFTP port" "2022")
    
    echo ""
    pulse_text "Configuring game ports" 2
    echo ""
    
    # Game ports with interactive selection
    declare -a GAME_PORTS=()
    
    # Minecraft Java
    read -p "$(echo -e ${CYAN}➜${NC} Host Minecraft Java servers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        MC_PORT=$(get_custom_port_animated "Enter Minecraft Java port" "25565")
        GAME_PORTS+=("$MC_PORT:Minecraft-Java:both")
    fi
    
    # Minecraft Bedrock
    read -p "$(echo -e ${CYAN}➜${NC} Host Minecraft Bedrock servers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        MCB_PORT=$(get_custom_port_animated "Enter Minecraft Bedrock port" "19132")
        GAME_PORTS+=("$MCB_PORT:Minecraft-Bedrock:both")
    fi
    
    # Source Games
    read -p "$(echo -e ${CYAN}➜${NC} Host Source Engine games? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        SOURCE_PORT=$(get_custom_port_animated "Enter Source Engine port" "27015")
        GAME_PORTS+=("$SOURCE_PORT:Source-Engine:both")
    fi
    
    # Rust
    read -p "$(echo -e ${CYAN}➜${NC} Host Rust servers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        RUST_PORT=$(get_custom_port_animated "Enter Rust port" "28015")
        GAME_PORTS+=("$RUST_PORT:Rust:both")
    fi
    
    # ARK
    read -p "$(echo -e ${CYAN}➜${NC} Host ARK servers? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ARK_PORT=$(get_custom_port_animated "Enter ARK port" "7777")
        GAME_PORTS+=("$ARK_PORT:ARK:both")
    fi
    
    # Custom ports
    while true; do
        read -p "$(echo -e ${CYAN}➜${NC} Add custom port? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            break
        fi
        
        CUSTOM_PORT=$(get_custom_port_animated "Enter custom port number" "")
        read -p "$(echo -e ${CYAN}➜${NC} Protocol (tcp/udp/both): " CUSTOM_PROTO
        read -p "$(echo -e ${CYAN}➜${NC} Description: " CUSTOM_DESC
        
        GAME_PORTS+=("$CUSTOM_PORT:$CUSTOM_DESC:$CUSTOM_PROTO")
    done
    
    # Display summary
    clear
    animated_astra_logo
    echo -e "${GREEN}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║         PORT CONFIGURATION SUMMARY        ║${NC}"
    echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}▶ SSH:${NC} $SSH_PORT"
    echo -e "${CYAN}▶ HTTP:${NC} $HTTP_PORT"
    echo -e "${CYAN}▶ HTTPS/ Panel:${NC} $PANEL_PORT"
    echo -e "${CYAN}▶ Wings API:${NC} $WINGS_API_PORT"
    echo -e "${CYAN}▶ Wings SFTP:${NC} $WINGS_SFTP_PORT"
    echo ""
    echo -e "${YELLOW}Game Ports:${NC}"
    for entry in "${GAME_PORTS[@]}"; do
        IFS=':' read -r port name protocol <<< "$entry"
        echo -e "  ${GREEN}•${NC} $name: $port ($protocol)"
    done
    echo ""
    
    read -p "$(echo -e ${GREEN}➜${NC} Continue with installation? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

# Apply firewall with animation
apply_firewall_animated() {
    echo ""
    echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}│     CONFIGURING FIREWALL RULES         │${NC}"
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    # Enable UFW with animation
    echo -ne "${YELLOW}▶${NC} Enabling UFW firewall "
    for i in {1..3}; do
        echo -ne "${BLUE}.${NC}"
        sleep 0.3
    done
    sudo ufw --force enable > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Add SSH rule
    echo -ne "${YELLOW}▶${NC} Adding SSH port $SSH_PORT "
    sudo ufw allow $SSH_PORT/tcp > /dev/null 2>&1
    sleep 0.5
    echo -e " ${GREEN}✓${NC}"
    
    # Add web ports
    echo -ne "${YELLOW}▶${NC} Adding web ports "
    sudo ufw allow $HTTP_PORT/tcp > /dev/null 2>&1
    sudo ufw allow $PANEL_PORT/tcp > /dev/null 2>&1
    sleep 0.5
    echo -e " ${GREEN}✓${NC}"
    
    # Add Wings ports
    echo -ne "${YELLOW}▶${NC} Adding Wings ports "
    sudo ufw allow $WINGS_API_PORT/tcp > /dev/null 2>&1
    sudo ufw allow $WINGS_SFTP_PORT/tcp > /dev/null 2>&1
    sleep 0.5
    echo -e " ${GREEN}✓${NC}"
    
    # Add game ports with progress
    echo -e "${YELLOW}▶${NC} Adding game ports..."
    total_ports=${#GAME_PORTS[@]}
    current=0
    
    for entry in "${GAME_PORTS[@]}"; do
        IFS=':' read -r port name protocol <<< "$entry"
        current=$((current + 1))
        
        echo -ne "   ${BLUE}[${current}/${total_ports}]${NC} Adding $name ($port) "
        
        case "$protocol" in
            tcp)
                sudo ufw allow $port/tcp > /dev/null 2>&1
                ;;
            udp)
                sudo ufw allow $port/udp > /dev/null 2>&1
                ;;
            both)
                sudo ufw allow $port/tcp > /dev/null 2>&1
                sudo ufw allow $port/udp > /dev/null 2>&1
                ;;
        esac
        
        sleep 0.2
        echo -e " ${GREEN}✓${NC}"
    done
    
    # Reload firewall
    echo -ne "${YELLOW}▶${NC} Reloading firewall rules "
    sudo ufw reload > /dev/null 2>&1
    sleep 0.5
    echo -e " ${GREEN}✓${NC}"
    
    echo ""
    echo -e "${GREEN}✓ Firewall configuration complete!${NC}"
    sleep 2
}

# Main installation with progress animation
main_installation_animated() {
    clear
    animated_astra_logo
    
    echo -e "${WHITE}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}${BOLD}║         INSTALLATION PROGRESS             ║${NC}"
    echo -e "${WHITE}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get domain and basic info
    echo -ne "${CYAN}➜${NC} Enter your domain: "
    read DOMAIN
    echo -ne "${CYAN}➜${NC} Enter your email for SSL: "
    read EMAIL
    echo -ne "${CYAN}➜${NC} Enter database password: "
    read -s DB_PASSWORD
    echo ""
    echo -ne "${CYAN}➜${NC} Enter admin password: "
    read -s ADMIN_PASSWORD
    echo ""
    echo ""
    
    # Configure ports
    configure_ports_animated
    
    # Installation steps with progress
    steps=12
    current=0
    
    # Step 1: Update system
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Updating system "
    sudo apt update > /dev/null 2>&1 && sudo apt upgrade -y > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 2: Install Docker
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing Docker "
    curl -fsSL https://get.docker.com | sudo CHANNEL=stable bash > /dev/null 2>&1
    sudo systemctl enable --now docker > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 3: Install MariaDB
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing MariaDB "
    sudo apt install -y mariadb-server mariadb-client > /dev/null 2>&1
    sudo systemctl enable --now mariadb > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 4: Configure database
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Configuring database "
    sudo mysql -e "CREATE DATABASE panel;" > /dev/null 2>&1
    sudo mysql -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';" > /dev/null 2>&1
    sudo mysql -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1';" > /dev/null 2>&1
    sudo mysql -e "FLUSH PRIVILEGES;" > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 5: Install PHP
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing PHP 8.1 "
    sudo add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
    sudo apt update > /dev/null 2>&1
    sudo apt install -y php8.1 php8.1-{cli,common,curl,fpm,gd,intl,mysql,mbstring,xml,zip,bcmath,soap} > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 6: Install Nginx
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing Nginx "
    sudo apt install -y nginx > /dev/null 2>&1
    sudo systemctl enable --now nginx > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 7: Install Composer
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing Composer "
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 8: Install Pterodactyl Panel
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing Pterodactyl Panel "
    cd /var/www > /dev/null 2>&1
    sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz > /dev/null 2>&1
    sudo tar -xzf panel.tar.gz > /dev/null 2>&1
    sudo mv panel-* pterodactyl > /dev/null 2>&1
    cd pterodactyl > /dev/null 2>&1
    sudo cp .env.example .env > /dev/null 2>&1
    sudo composer install --no-dev --optimize-autoloader > /dev/null 2>&1
    sudo php artisan key:generate --force > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 9: Configure Panel
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Configuring Panel "
    sudo php artisan p:environment:setup --author=$EMAIL --url=https://$DOMAIN:$PANEL_PORT --timezone=UTC > /dev/null 2>&1
    sudo php artisan p:environment:database --host=127.0.0.1 --port=3306 --database=panel --username=pterodactyl --password=$DB_PASSWORD > /dev/null 2>&1
    sudo php artisan migrate --seed --force > /dev/null 2>&1
    sudo php artisan p:user:make --email=admin@$DOMAIN --username=admin --name-first=Admin --password=$ADMIN_PASSWORD --admin=1 > /dev/null 2>&1
    sudo chown -R www-data:www-data /var/www/pterodactyl/* > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 10: Install Wings
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing Wings "
    sudo mkdir -p /etc/pterodactyl /var/lib/pterodactyl > /dev/null 2>&1
    sudo curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/wings > /dev/null 2>&1
    sudo useradd -r -d /var/lib/pterodactyl -s /usr/sbin/nologin wings > /dev/null 2>&1
    sudo usermod -aG docker wings > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 11: Configure Nginx with custom ports
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Configuring Nginx "
    sudo tee /etc/nginx/sites-available/pterodactyl > /dev/null << EOF
server {
    listen $HTTP_PORT;
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
}
EOF
    sudo ln -sf /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/ > /dev/null 2>&1
    sudo rm -f /etc/nginx/sites-enabled/default > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Step 12: Install SSL and finalize
    current=$((current + 1))
    echo -ne "\r${CYAN}[${current}/${steps}]${NC} Installing SSL certificate "
    sudo apt install -y certbot python3-certbot-nginx > /dev/null 2>&1
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL > /dev/null 2>&1
    sudo systemctl restart nginx > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    
    # Apply firewall rules
    apply_firewall_animated
    
    # Install Blueprint
    echo ""
    echo -e "${CYAN}${BOLD}┌─────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}${BOLD}│     INSTALLING BLUEPRINT               │${NC}"
    echo -e "${CYAN}${BOLD}└─────────────────────────────────────────┘${NC}"
    echo ""
    
    cd /var/www/pterodactyl
    sudo php artisan down > /dev/null 2>&1
    echo -ne "${YELLOW}▶${NC} Installing Blueprint framework "
    sudo curl -L https://github.com/BlueprintFramework/framework/raw/1.1.0/scripts/install.sh | sudo bash > /dev/null 2>&1
    echo -e " ${GREEN}✓${NC}"
    sudo php artisan up > /dev/null 2>&1
    
    # Save configuration
    cat > ~/astra-config.txt << EOF
========================================
ASTRA Pterodactyl Installation Complete
========================================

Panel URL: https://$DOMAIN:$PANEL_PORT
Username: admin
Password: $ADMIN_PASSWORD

Port Configuration:
- SSH: $SSH_PORT
- HTTP: $HTTP_PORT
- Panel Port: $PANEL_PORT
- Wings API: $WINGS_API_PORT
- Wings SFTP: $WINGS_SFTP_PORT

Game Ports:
$(for entry in "${GAME_PORTS[@]}"; do
    IFS=':' read -r port name protocol <<< "$entry"
    echo "- $name: $port ($protocol)"
done)

========================================
EOF
    
    # Final animation
    clear
    animated_astra_logo
    
    echo -e "${GREEN}${BOLD}"
    echo "╔════════════════════════════════════════════╗"
    echo "║         INSTALLATION COMPLETE!             ║"
    echo "║            WELCOME TO ASTRA                ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    pulse_text "Finalizing setup" 3
    
    echo ""
    echo -e "${CYAN}▶ Panel URL:${NC} https://$DOMAIN:$PANEL_PORT"
    echo -e "${CYAN}▶ Username:${NC} admin"
    echo -e "${CYAN}▶ Password:${NC} $ADMIN_PASSWORD"
    echo ""
    echo -e "${YELLOW}📁 Configuration saved to: ~/astra-config.txt${NC}"
    echo ""
    echo -e "${GREEN}To configure Wings:${NC}"
    echo "1. Login to panel: https://$DOMAIN:$PANEL_PORT"
    echo "2. Go to Admin → Nodes → Create New Node"
    echo "3. Copy configuration URL"
    echo "4. Run: sudo curl -o /etc/pterodactyl/config.yml <CONFIGURATION_URL>"
    echo "5. Run: sudo systemctl start wings"
    echo ""
    echo -e "${MAGENTA}✨ ASTRA Installation Complete! ✨${NC}"
}

# Run the animated installer
main_installation_animated
