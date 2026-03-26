#!/bin/bash

# ================================================================
#   🐉  ICONIC PTERODACTYL PANEL FIXER
#   Fixes Nginx configuration and ensures panel loads properly
#   Adds ICONIC branding to the panel
# ================================================================

# Colors
R='\033[0;31m'
G='\033[0;32m'
LG='\033[1;32m'
Y='\033[1;33m'
B='\033[0;34m'
LB='\033[1;34m'
M='\033[0;35m'
C='\033[0;36m'
LC='\033[1;36m'
W='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${LC}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     🐉  ICONIC PTERODACTYL PANEL FIXER  🐉               ║"
echo "║     Making your panel actually work!                     ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running as root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${R}Error: Please run as root (sudo bash fix-panel.sh)${NC}"
    exit 1
fi

# Function to log messages
log_info() {
    echo -e "${LC}[INFO]${NC} $1"
}

log_success() {
    echo -e "${LG}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${R}[ERROR]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${LB}────────────────────────────────────────────────────${NC}"
    echo -e "${LB}▶ $1${NC}"
    echo -e "${LB}────────────────────────────────────────────────────${NC}"
}

# Get domain/IP from user
get_domain() {
    echo ""
    echo -e "${W}Enter your domain or IP address:${NC}"
    echo -e "${DIM}(e.g., panel.example.com or 192.168.1.100)${NC}"
    read -p "→ " DOMAIN
    
    if [[ -z "$DOMAIN" ]]; then
        echo -e "${R}Domain/IP cannot be empty!${NC}"
        get_domain
    fi
}

# Step 1: Check if panel files exist
log_step "Step 1: Checking Pterodactyl Panel Installation"

if [[ ! -d "/var/www/pterodactyl" ]]; then
    log_error "Pterodactyl panel not found in /var/www/pterodactyl"
    echo -e "${Y}Please install the panel first using Option 1 in the main installer${NC}"
    exit 1
fi

if [[ ! -f "/var/www/pterodactyl/public/index.php" ]]; then
    log_error "Panel files appear to be corrupted or incomplete"
    exit 1
fi

log_success "Panel files found"

# Step 2: Fix permissions
log_step "Step 2: Fixing Permissions"

log_info "Setting correct ownership..."
chown -R www-data:www-data /var/www/pterodactyl/* 2>/dev/null
chmod -R 755 /var/www/pterodactyl/storage /var/www/pterodactyl/bootstrap/cache 2>/dev/null
log_success "Permissions fixed"

# Step 3: Configure PHP
log_step "Step 3: Configuring PHP"

log_info "Checking PHP-FPM..."
if systemctl is-active --quiet php8.1-fpm; then
    log_success "PHP-FPM is running"
else
    log_info "Starting PHP-FPM..."
    systemctl start php8.1-fpm
    systemctl enable php8.1-fpm
fi

# Step 4: Remove default Nginx site and configure Pterodactyl
log_step "Step 4: Configuring Nginx"

get_domain

log_info "Removing default Nginx site..."
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default

# Create optimized Nginx configuration
log_info "Creating Pterodactyl Nginx configuration..."

cat > /etc/nginx/sites-available/pterodactyl <<'NGINXEOF'
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;
    root /var/www/pterodactyl/public;
    index index.php;
    
    # SSL (will be configured with Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # Logging
    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log /var/log/nginx/pterodactyl.app-error.log error;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    client_max_body_size 100m;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
NGINXEOF

# Replace domain placeholder
sed -i "s/DOMAIN_PLACEHOLDER/$DOMAIN/g" /etc/nginx/sites-available/pterodactyl

# Enable the site
ln -sf /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/pterodactyl

# Test Nginx configuration
if nginx -t 2>/dev/null; then
    log_success "Nginx configuration is valid"
else
    log_error "Nginx configuration has errors"
    nginx -t
    exit 1
fi

# Step 5: Install SSL Certificate (if domain, not IP)
log_step "Step 5: Setting up SSL"

if [[ "$DOMAIN" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ "$DOMAIN" == "localhost" ]]; then
    log_info "Using IP address - SSL not available"
    # Modify config to work without SSL
    sed -i 's|return 301 https|#return 301 https|g' /etc/nginx/sites-available/pterodactyl
    sed -i 's|listen 443 ssl http2;|listen 80;|g' /etc/nginx/sites-available/pterodactyl
    sed -i '/ssl_/d' /etc/nginx/sites-available/pterodactyl
    log_info "Using HTTP only (no SSL)"
else
    log_info "Installing SSL certificate for $DOMAIN..."
    
    # Install certbot if not installed
    if ! command -v certbot &> /dev/null; then
        apt-get update -qq
        apt-get install -y certbot python3-certbot-nginx -qq
    fi
    
    # Try to get SSL certificate
    if certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" 2>/dev/null; then
        log_success "SSL certificate installed successfully"
    else
        log_error "SSL installation failed - using HTTP only"
        sed -i 's|return 301 https|#return 301 https|g' /etc/nginx/sites-available/pterodactyl
        sed -i 's|listen 443 ssl http2;|listen 80;|g' /etc/nginx/sites-available/pterodactyl
        sed -i '/ssl_/d' /etc/nginx/sites-available/pterodactyl
    fi
fi

# Step 6: Restart services
log_step "Step 6: Restarting Services"

systemctl restart nginx
systemctl restart php8.1-fpm
log_success "Services restarted"

# Step 7: Add ICONIC branding to panel
log_step "Step 7: Adding ICONIC Branding"

# Update panel title
if [[ -f "/var/www/pterodactyl/resources/views/layouts/admin.blade.php" ]]; then
    sed -i 's/<title>.*<\/title>/<title>ICONIC Panel | Pterodactyl<\/title>/g' /var/www/pterodactyl/resources/views/layouts/admin.blade.php
    sed -i 's/<title>.*<\/title>/<title>ICONIC Panel | Pterodactyl<\/title>/g' /var/www/pterodactyl/resources/views/layouts/master.blade.php
fi

# Update login page branding
if [[ -f "/var/www/pterodactyl/resources/views/auth/login.blade.php" ]]; then
    sed -i 's/Pterodactyl Panel/ICONIC Panel/g' /var/www/pterodactyl/resources/views/auth/login.blade.php
fi

# Create custom CSS for ICONIC branding
mkdir -p /var/www/pterodactyl/public/css/custom
cat > /var/www/pterodactyl/public/css/custom/iconic.css <<'CSSEOF'
/* ICONIC Panel Custom Styles */
:root {
    --iconic-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    --iconic-glow: 0 0 20px rgba(102, 126, 234, 0.5);
}

.navbar-brand::after {
    content: " ✦ ICONIC";
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    font-weight: bold;
}

.brand-logo {
    position: relative;
}

.brand-logo::before {
    content: "🐉";
    margin-right: 8px;
    animation: pulse 2s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.6; text-shadow: 0 0 10px #667eea; }
}
CSSEOF

# Add CSS to layout
if [[ -f "/var/www/pterodactyl/resources/views/layouts/master.blade.php" ]]; then
    sed -i '/<\/head>/i <link rel="stylesheet" href="/css/custom/iconic.css">' /var/www/pterodactyl/resources/views/layouts/master.blade.php
fi

# Clear cache to apply changes
cd /var/www/pterodactyl
php artisan view:clear
php artisan cache:clear
php artisan config:clear

log_success "ICONIC branding applied"

# Step 8: Final checks
log_step "Step 8: Final Verification"

# Check if queue worker is running
if ! supervisorctl status pterodactyl-worker:* 2>/dev/null | grep -q RUNNING; then
    log_info "Starting queue worker..."
    supervisorctl reread 2>/dev/null
    supervisorctl update 2>/dev/null
    supervisorctl start pterodactyl-worker:* 2>/dev/null
fi

# Display final URL
echo ""
echo -e "${LG}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${LG}${BOLD}║     ✅  PANEL INSTALLATION COMPLETE!  ✅                   ║${NC}"
echo -e "${LG}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${W}${BOLD}📌 Panel URL:${NC} ${LC}https://${DOMAIN}${NC}"
echo ""
echo -e "${W}${BOLD}🔐 Default Admin Login:${NC}"
echo -e "   ${Y}Username:${NC} admin"
echo -e "   ${Y}Password:${NC} (the password you set during installation)"
echo ""
echo -e "${W}${BOLD}📝 Next Steps:${NC}"
echo -e "   1. Access your panel at: ${LC}https://${DOMAIN}${NC}"
echo -e "   2. Login with your admin credentials"
echo -e "   3. Go to Admin → Nodes → Create New Node"
echo -e "   4. Configure Wings on your node server"
echo ""
echo -e "${LG}✨ Your ICONIC Pterodactyl Panel is now ready! ✨${NC}"
echo ""

# Ask if user wants to open panel now
read -p "Do you want to open the panel URL? (y/n): " OPEN_PANEL
if [[ "$OPEN_PANEL" == "y" ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://$DOMAIN"
    else
        echo -e "${Y}Please open https://$DOMAIN in your browser${NC}"
    fi
fi
