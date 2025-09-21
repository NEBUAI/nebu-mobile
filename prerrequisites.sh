#!/bin/bash

# ==============================================
# OUTLIERS ACADEMY - PREREQUISITES INSTALLER
# ==============================================

set -e  # Exit on any error

# Configuration - will be loaded from .env if available
DOMAIN=""
EXPECTED_IP=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to load configuration from .env file
load_config() {
    print_status "Loading configuration..."
    
    if [ -f ".env" ]; then
        # Load domain from .env
        DOMAIN=$(grep "^DOMAIN=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'")
        
        if [ -z "$DOMAIN" ]; then
            print_warning "DOMAIN not found in .env, using default: localhost"
            DOMAIN="localhost"
        else
            print_success "Domain loaded from .env: $DOMAIN"
        fi
    else
        print_warning ".env file not found, using localhost for domain"
        DOMAIN="localhost"
    fi
    
    # Get current server IP automatically
    if command -v curl >/dev/null 2>&1; then
        print_status "Detecting server public IP..."
        EXPECTED_IP=$(curl -s --connect-timeout 5 https://ipinfo.io/ip 2>/dev/null || curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || echo "")
        
        if [ -n "$EXPECTED_IP" ]; then
            print_success "Detected public IP: $EXPECTED_IP"
        else
            print_warning "Could not detect public IP automatically"
            # Try to get local IP as fallback
            EXPECTED_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
            print_warning "Using local IP as fallback: $EXPECTED_IP"
        fi
    else
        print_warning "curl not available, cannot detect public IP"
        EXPECTED_IP="127.0.0.1"
    fi
}

# Function to get current server info
get_server_info() {
    print_status "Server Information:"
    echo "  Domain: $DOMAIN"
    echo "  Expected IP: $EXPECTED_IP"
    echo "  Local IP: $(hostname -I | awk '{print $1}' 2>/dev/null || echo 'unknown')"
    echo "  Hostname: $(hostname 2>/dev/null || echo 'unknown')"
}

# Function to check DNS resolution
check_dns() {
    local domain=$1
    local expected_ip=$2
    
    # Skip DNS check for localhost or if no domain configured
    if [ "$domain" = "localhost" ] || [ -z "$domain" ]; then
        print_warning "Skipping DNS check for localhost/empty domain"
        return 0
    fi
    
    print_status "Checking DNS resolution for $domain..."
    
    if command -v nslookup >/dev/null 2>&1; then
        local resolved_ip=$(nslookup $domain 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
        
        if [ -n "$resolved_ip" ]; then
            if [ "$resolved_ip" = "$expected_ip" ]; then
                print_success "DNS resolution correct: $domain -> $resolved_ip"
                return 0
            else
                print_warning "DNS resolution mismatch: $domain -> $resolved_ip (expected: $expected_ip)"
                print_status "This might be okay if you're using a CDN or load balancer"
                return 0  # Don't fail, just warn
            fi
        else
            print_warning "Could not resolve $domain"
            print_status "SSL certificate generation may fail if domain is not accessible"
            return 0  # Don't fail, just warn
        fi
    else
        print_warning "nslookup not available, installing dnsutils..."
        sudo apt install -y dnsutils
        check_dns $domain $expected_ip
    fi
}

# Function to check firewall ports
check_firewall() {
    print_status "Checking firewall configuration..."
    
    if command -v ufw >/dev/null 2>&1; then
        local ufw_status=$(sudo ufw status | head -1)
        if [[ "$ufw_status" == *"active"* ]]; then
            print_status "UFW is active, checking port rules..."
            
            # Check if ports 80 and 443 are allowed
            if sudo ufw status | grep -q -E "(80/tcp|80 )" ; then
                print_success "Port 80 (HTTP) is allowed"
            else
                print_warning "Port 80 (HTTP) not explicitly allowed"
                print_status "Adding UFW rule for port 80..."
                sudo ufw allow 80/tcp || print_warning "Failed to add UFW rule for port 80"
            fi
            
            if sudo ufw status | grep -q -E "(443/tcp|443 )"; then
                print_success "Port 443 (HTTPS) is allowed"
            else
                print_warning "Port 443 (HTTPS) not explicitly allowed"
                print_status "Adding UFW rule for port 443..."
                sudo ufw allow 443/tcp || print_warning "Failed to add UFW rule for port 443"
            fi
        else
            print_warning "UFW is not active"
            print_status "To enable UFW later, run: sudo ufw enable"
        fi
    else
        print_warning "UFW not installed"
        if command -v iptables >/dev/null 2>&1; then
            print_status "Iptables available - manual firewall configuration may be needed"
        elif command -v firewall-cmd >/dev/null 2>&1; then
            print_status "FirewallD detected - manual configuration may be needed"
        else
            print_status "No recognized firewall found"
        fi
    fi
}

# Function to check SSL prerequisites
check_ssl_prerequisites() {
    print_status "Checking SSL prerequisites..."
    
    # Ensure directory exists
    if [ ! -d "./gateway/letsencrypt" ]; then
        print_status "Creating letsencrypt directory..."
        mkdir -p ./gateway/letsencrypt
    fi
    
    # Check if acme.json exists and has correct permissions
    if [ -f "./gateway/letsencrypt/acme.json" ]; then
        local perms=$(stat -c "%a" ./gateway/letsencrypt/acme.json 2>/dev/null || echo "unknown")
        if [ "$perms" = "600" ]; then
            print_success "acme.json has correct permissions (600)"
        else
            print_warning "acme.json permissions incorrect ($perms), fixing..."
            chmod 600 ./gateway/letsencrypt/acme.json
            print_success "acme.json permissions fixed"
        fi
    else
        print_status "Creating acme.json file..."
        touch ./gateway/letsencrypt/acme.json
        chmod 600 ./gateway/letsencrypt/acme.json
        print_success "acme.json created with correct permissions"
    fi
    
    # Initialize with empty JSON if file is empty
    if [ ! -s "./gateway/letsencrypt/acme.json" ]; then
        echo '{}' > ./gateway/letsencrypt/acme.json
        chmod 600 ./gateway/letsencrypt/acme.json
        print_status "acme.json initialized with empty JSON"
    fi
}

# Function to check environment variables
check_environment() {
    print_status "Checking environment configuration..."
    
    if [ -f ".env" ]; then
        print_success "Environment file (.env) exists"
        
        # Check critical environment variables
        local missing_vars=()
        
        if ! grep -q "^DOMAIN=" .env; then
            missing_vars+=("DOMAIN")
        fi
        
        if ! grep -q "^ACME_EMAIL=" .env; then
            missing_vars+=("ACME_EMAIL")
        fi
        
        if ! grep -q "^JWT_SECRET=" .env; then
            missing_vars+=("JWT_SECRET")
        fi
        
        if [ ${#missing_vars[@]} -eq 0 ]; then
            print_success "All critical environment variables are configured"
        else
            print_error "Missing environment variables: ${missing_vars[*]}"
            print_status "Please ensure these variables are set in your .env file"
            return 1
        fi
    else
        print_error "Environment file (.env) not found!"
        print_status "Please copy template.env to .env and configure it"
        return 1
    fi
}

# Function to test network connectivity
test_connectivity() {
    print_status "Testing network connectivity..."
    
    # Test internet connectivity
    if curl -s --connect-timeout 5 https://google.com >/dev/null; then
        print_success "Internet connectivity OK"
    else
        print_error "No internet connectivity"
        return 1
    fi
    
    # Test Let's Encrypt connectivity
    if curl -s --connect-timeout 5 https://acme-v02.api.letsencrypt.org/directory >/dev/null; then
        print_success "Let's Encrypt API accessible"
    else
        print_error "Cannot reach Let's Encrypt API"
        return 1
    fi
}

# Detect package manager and OS
detect_os() {
    if command -v apt >/dev/null 2>&1; then
        OS="debian"
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt install -y"
        UPDATE_CMD="sudo apt update"
    elif command -v yum >/dev/null 2>&1; then
        OS="redhat"
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        UPDATE_CMD="sudo yum update"
    elif command -v dnf >/dev/null 2>&1; then
        OS="fedora"
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        UPDATE_CMD="sudo dnf update"
    elif command -v pacman >/dev/null 2>&1; then
        OS="arch"
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        UPDATE_CMD="sudo pacman -Sy"
    else
        print_warning "Could not detect package manager. Continuing with manual checks..."
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
    
    print_status "Detected OS: $OS ($PKG_MANAGER)"
}

# Check if Docker and Docker Compose are available
check_docker_availability() {
    if command -v docker >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
        print_success "Docker and Docker Compose are already available"
        return 0
    else
        if [ "$OS" = "unknown" ]; then
            print_error "Docker/Docker Compose not found and OS not supported for automatic installation."
            print_status "Please install Docker and Docker Compose manually:"
            print_status "1. Visit: https://docs.docker.com/engine/install/"
            print_status "2. Visit: https://docs.docker.com/compose/install/"
    exit 1
fi
        return 1
    fi
}

detect_os

print_status "Installing prerequisites for Outliers Academy..."

# Load configuration first
load_config
get_server_info

# Phase 1: Basic system checks and installations
echo -e "\n${BLUE}=== PHASE 1: SYSTEM SETUP ===${NC}"

# Check if Docker is already available
if check_docker_availability; then
    print_status "Skipping Docker installation - already available"
else
    # Only install if we have a supported package manager
    if [ "$OS" != "unknown" ]; then
# Update package list
print_status "Updating package list..."
        $UPDATE_CMD

        # Install basic dependencies based on OS
print_status "Installing basic dependencies..."
        case $OS in
            "debian")
                $INSTALL_CMD apt-transport-https ca-certificates curl gnupg lsb-release make git dnsutils net-tools
                ;;
            "redhat"|"fedora")
                $INSTALL_CMD ca-certificates curl gnupg make git bind-utils net-tools
                ;;
            "arch")
                $INSTALL_CMD curl gnupg make git bind-tools net-tools base-devel
                ;;
        esac
    fi
fi

# Install Docker
if command -v docker >/dev/null 2>&1; then
    print_success "Docker is already installed: $(docker --version)"
else
print_status "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
fi

# Install Docker Compose
if command -v docker-compose >/dev/null 2>&1; then
    print_success "Docker Compose is already installed: $(docker-compose --version)"
else
print_status "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
fi

# Add user to docker group (safe to run multiple times)
print_status "Ensuring user is in docker group..."
if groups $USER | grep -q docker; then
    print_success "User $USER is already in docker group"
else
print_status "Adding user to docker group..."
sudo usermod -aG docker $USER
    print_warning "You'll need to log out and back in for group changes to take effect"
fi

# Verify installations
print_status "Verifying installations..."
if command -v docker >/dev/null 2>&1; then
    print_success "Docker installed successfully: $(docker --version)"
else
    print_error "Docker installation failed!"
    exit 1
fi

if command -v docker-compose >/dev/null 2>&1; then
    print_success "Docker Compose installed successfully: $(docker-compose --version)"
else
    print_error "Docker Compose installation failed!"
    exit 1
fi

# Phase 2: SSL and Domain Configuration
echo -e "\n${BLUE}=== PHASE 2: SSL AND DOMAIN CONFIGURATION ===${NC}"

# Check environment configuration
if ! check_environment; then
    print_error "Environment configuration failed. Please fix and run again."
    exit 1
fi

# Check DNS resolution (only if domain is not localhost)
if [ "$DOMAIN" != "localhost" ] && [ -n "$DOMAIN" ]; then
    if ! check_dns "$DOMAIN" "$EXPECTED_IP"; then
        print_warning "DNS resolution issues detected. SSL certificates may fail to generate."
    fi
else
    print_status "Skipping DNS check for localhost/development environment"
fi

# Check SSL prerequisites
check_ssl_prerequisites

# Phase 3: Network and Security
echo -e "\n${BLUE}=== PHASE 3: NETWORK AND SECURITY ===${NC}"

# Check firewall configuration
check_firewall

# Test connectivity
if ! test_connectivity; then
    print_error "Network connectivity issues detected. Please check your internet connection."
    exit 1
fi

# Phase 4: Final Checks
echo -e "\n${BLUE}=== PHASE 4: FINAL VALIDATION ===${NC}"

# Check if ports are actually listening (if Docker is running)
print_status "Checking if required ports are available..."
if ss -tlnp | grep -q ":80 "; then
    print_warning "Port 80 is already in use"
    ss -tlnp | grep ":80 "
fi

if ss -tlnp | grep -q ":443 "; then
    print_warning "Port 443 is already in use"
    ss -tlnp | grep ":443 "
fi

# Summary
echo -e "\n${GREEN}=== INSTALLATION COMPLETE ===${NC}"
print_success "All prerequisites installed successfully!"

echo -e "\n${YELLOW}=== NEXT STEPS ===${NC}"
print_warning "IMPORTANT: You need to log out and log back in (or run 'newgrp docker') for Docker group changes to take effect."

echo -e "\n${BLUE}=== DEPLOYMENT COMMANDS ===${NC}"
print_status "For development: make dev"
print_status "For production:  make prod (includes SSL config generation)"
print_status "Manual config:   make config (generate SSL config only)"

if [ "$DOMAIN" != "localhost" ] && [ -n "$DOMAIN" ]; then
    echo -e "\n${BLUE}=== SSL CERTIFICATE NOTES ===${NC}"
    print_status "✅ SSL certificates will be automatically generated with dynamic configuration"
    print_status "✅ Configuration uses environment variable interpolation for security"
    print_status "✅ Make sure your domain ($DOMAIN) points to this server ($EXPECTED_IP)"
    print_status "✅ Let's Encrypt requires ports 80 and 443 to be accessible from the internet"
    
    echo -e "\n${BLUE}=== SSL CONFIGURATION PROCESS ===${NC}"
    print_status "1. 'make prod' automatically generates SSL config from template"
    print_status "2. Variables from .env are interpolated into Traefik configuration"
    print_status "3. Traefik requests certificates from Let's Encrypt production servers"
    print_status "4. Certificates are automatically renewed every 60 days"
    
    echo -e "\n${BLUE}=== TROUBLESHOOTING ===${NC}"
    print_status "If SSL certificate generation fails:"
    print_status "1. Verify DNS: nslookup $DOMAIN"
    print_status "2. Check firewall: sudo ufw status"
    print_status "3. Test connectivity: curl -I http://$DOMAIN"
    print_status "4. Check logs: docker logs outliers-academy-traefik"
    print_status "5. Regenerate config: make config && docker-compose restart traefik"
    print_status "6. Check SSL status: ./gateway/traefik-manager.sh certs"
else
    echo -e "\n${BLUE}=== DEVELOPMENT NOTES ===${NC}"
    print_status "Running in development mode (localhost)"
    print_status "SSL certificates are not required for localhost development"
    print_status "The application will be available at: http://localhost"
fi