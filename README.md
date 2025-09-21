# 🎓 Outliers Academy - Learning Management System

[![Docker](https://img.shields.io/badge/Docker-Enabled-blue.svg)](https://docker.com)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://postgresql.org)
[![Redis](https://img.shields.io/badge/Redis-7+-red.svg)](https://redis.io)

A modern, full-stack Learning Management System (LMS) built with **Next.js**, **NestJS**, **PostgreSQL**, and **Redis**, fully containerized with Docker.

## 🚀 Quick Start

### Prerequisites

- **Ubuntu/Debian** system with `apt` package manager
- **Internet connection** for downloading dependencies
- **sudo privileges** for package installation

### One-Command Installation

```bash
# Clone the repository
git clone <your-repository-url>
cd theme-outliers-academy

# Run the automated installer
./prerrequisites.sh

# Log out and log back in (or run: newgrp docker)
# Then start the application
make dev
```

That's it! Your application will be running at:
- 🌐 **Frontend**: http://localhost:3000
- 🔧 **Backend API**: http://localhost:3001
- 📊 **Traefik Dashboard**: http://localhost:8080

## 📋 Manual Installation

If you prefer to install dependencies manually:

### 1. Install Docker & Docker Compose

```bash
# Update package list
sudo apt update

# Install basic dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release make git

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

### 2. Configure Environment

```bash
# Copy environment template
cp template.env .env

# Edit with your credentials
nano .env
```

### 3. Start the Application

```bash
# Start all services
make dev

# Or manually with Docker Compose
docker-compose up -d
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   Database      │
│   (Next.js)     │◄──►│   (NestJS)      │◄──►│   (PostgreSQL)  │
│   Port: 3000    │    │   Port: 3001    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Cache/Session │
                    │   (Redis)       │
                    │   Port: 6379    │
                    └─────────────────┘
```

## 🛠️ Available Commands

### Development Commands

```bash
make dev              # Start development environment
make start            # Start all services
make stop             # Stop all services
make restart          # Restart all services
make status           # Show service status
```

### Database Commands

```bash
make db-init          # Initialize databases
make db-migrate       # Run database migrations
make db-seed          # Seed database with initial data
make db-backup        # Create database backup
```

### Monitoring & Debugging

```bash
make logs             # Show logs for all services
make logs-service     # Show logs for specific service (make logs-service SERVICE=backend)
make health           # Run health checks
make ps               # Show running containers
```

### Utility Commands

```bash
make shell-backend    # Access backend container shell
make shell-postgres   # Access PostgreSQL shell
make shell-redis      # Access Redis shell
make clean            # Clean up Docker resources
```

### Production Commands

```bash
make prod             # Start production environment with SSL config generation
make prod-legacy      # Start production without SSL config generation (legacy)
make config           # Generate Traefik SSL configuration only
make backup           # Create full system backup
make restore          # Restore from backup (make restore DATE=20240101)
```

### SSL Configuration Commands

```bash
make config           # Generate SSL configuration with environment variables
./gateway/traefik-manager.sh certs    # Check SSL certificate status
./gateway/traefik-manager.sh setup    # Setup SSL directories and permissions
```

## 🔧 Configuration

### Environment Variables

Edit `.env` file with your credentials:

```bash
# Database
DATABASE_PASSWORD=your_database_password_here

# Authentication
JWT_SECRET=your_jwt_secret_here
NEXTAUTH_SECRET=your_nextauth_secret_here

# OAuth (Optional)
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here

# Stripe (Optional)
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here

# Cloudinary (Optional)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name_here
CLOUDINARY_API_KEY=your_cloudinary_api_key_here
CLOUDINARY_API_SECRET=your_cloudinary_api_secret_here
```

### SSL Configuration (Production)

For production deployments with SSL certificates:

```bash
# Required environment variables
DOMAIN=your-domain.com
ACME_EMAIL=admin@your-domain.com
```

**SSL Features:**
- ✅ Automatic Let's Encrypt certificate generation
- ✅ Environment variable interpolation for security
- ✅ Automatic certificate renewal
- ✅ HTTP to HTTPS redirection
- ✅ Modern TLS configuration (TLS 1.2+)

### External Services Setup

1. **Stripe**: Configure in Stripe Dashboard (test mode)
2. **Cloudinary**: Set up in Cloudinary Dashboard for image uploads
3. **OAuth**: Configure Google/GitHub OAuth apps (optional)

## 📁 Project Structure

```
theme-outliers-academy/
├── 📁 backend/                 # NestJS Backend API
│   ├── src/
│   │   ├── auth/              # Authentication & Authorization
│   │   ├── courses/           # Course Management
│   │   ├── users/             # User Management
│   │   ├── payments/          # Stripe Integration
│   │   └── ...
│   └── Dockerfile
├── 📁 frontend/               # Next.js Frontend
│   ├── src/
│   │   ├── app/               # App Router Pages
│   │   ├── components/        # React Components
│   │   └── lib/               # Utilities
│   └── Dockerfile
├── 📁 scripts/                # Automation Scripts
├── 📁 db/                     # Database Scripts & Backups
├── 📁 gateway/                # Traefik Configuration
├── 📁 monitoring/             # Grafana & Prometheus
├── 📁 n8n/                    # Automation Workflows
├── docker-compose.yml         # Main Docker Compose
├── Makefile                   # Development Commands
├── prerrequisites.sh          # Automated Installer
└── template.env               # Environment Template
```

## 🐳 Docker Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **frontend** | Custom Next.js | 3000 | Main application frontend |
| **backend** | Custom NestJS | 3001 | REST API and business logic |
| **postgres** | postgres:15-alpine | 5432 | Primary database |
| **redis** | redis:7-alpine | 6379 | Cache and session store |
| **traefik** | traefik:v3.0 | 80/443 | Reverse proxy and load balancer |
| **n8n** | n8nio/n8n:latest | 5678 | Automation workflows |

## 🔍 Health Checks

All services include health checks. Monitor status with:

```bash
make health
```

Individual service health:
- Frontend: http://localhost:3000/api/health
- Backend: http://localhost:3001/api/v1/health
- Traefik: http://localhost:8080/ping

## 🚨 Troubleshooting

### Common Issues

1. **Docker permission denied**
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

2. **Port already in use**
   ```bash
   make stop
   # Check what's using the port
   sudo netstat -tulpn | grep :3000
   ```

3. **Database connection failed**
   ```bash
   make db-init
   make db-migrate
   ```

4. **Environment variables not loaded**
   ```bash
   cp template.env .env
   # Edit .env with your values
   ```

### Reset Everything

```bash
make clean-all  # WARNING: This removes all data!
```

## 📊 Monitoring

Access monitoring dashboards:
- **Traefik**: http://localhost:8080
- **N8N**: http://localhost:5678 (admin/admin123)

## 🔒 Security

- All services run in isolated Docker networks
- Environment variables for sensitive data
- JWT authentication with refresh tokens
- Rate limiting and CORS protection
- Security headers via Traefik

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make dev`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review logs with `make logs`
3. Run health checks with `make health`
4. Create an issue in the repository

---

**Made with ❤️ for Outliers Academy**
