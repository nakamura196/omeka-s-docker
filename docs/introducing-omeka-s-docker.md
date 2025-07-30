# Introducing Omeka S Docker: A Modern, Secure Solution for Digital Collections

Welcome to Omeka S Docker! This project provides a production-ready Docker setup for Omeka S, the web publication system for universities, galleries, libraries, archives, and museums.

📦 **GitHub Repository**: [https://github.com/nakamura196/omeka-s-docker](https://github.com/nakamura196/omeka-s-docker)

## Why Omeka S Docker?

Managing digital collections shouldn't be complicated. That's why we created this Docker-based solution that simplifies the deployment and management of Omeka S.

### Key Features

- **🚀 Quick Setup**: Get Omeka S running in minutes with a single command
- **🔒 Security First**: Built with security best practices, including non-root containers and secure defaults
- **📦 Module Management**: Automated installation and updates for popular Omeka S modules
- **🔄 Easy Upgrades**: Seamless version upgrades with data persistence
- **🐳 Production Ready**: Optimized for both development and production environments
- **🌐 Traefik Integration**: Built-in support for reverse proxy and SSL termination

## Getting Started

### Prerequisites
- Docker and Docker Compose installed
- Basic familiarity with command line
- (Optional) Domain name for production deployments with SSL

### Understanding the Setup Options

This Docker setup provides two deployment modes:

1. **Local Development Environment** - Perfect for testing, development, and small-scale deployments
2. **Production Environment with Traefik** - For public-facing sites with automatic SSL certificates

### Local Development Setup

The local setup is ideal for:
- Testing Omeka S before production deployment
- Development and customization work
- Internal use within organizations
- Small-scale projects without public access needs

#### Quick Start for Local Development

1. Clone the repository:
   ```bash
   git clone https://github.com/nakamura196/omeka-s-docker.git
   cd omeka-s-docker
   ```

2. Configure your environment:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. Start the services:
   ```bash
   docker-compose up -d
   ```

4. Access your services:
   - Omeka S: `http://localhost`
   - phpMyAdmin (database management): `http://localhost:8080`
   - Mailpit (email testing): `http://localhost:8025`

### Production Setup with Traefik

For public-facing deployments, we use Traefik as a reverse proxy. Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. Key benefits include:

- **Automatic SSL/TLS certificates** from Let's Encrypt (free!)
- **Automatic certificate renewal** - no manual intervention needed
- **Built-in security headers** for better protection
- **Dashboard for monitoring** your services
- **Docker integration** - automatically discovers services

#### What is a Reverse Proxy?

A reverse proxy sits between the internet and your web application, handling:
- SSL termination (HTTPS encryption/decryption)
- Load balancing across multiple containers
- Security headers and access control
- Routing requests to the correct service

#### Production Quick Start

1. Set up your domain:
   - Point your domain (e.g., `omeka.yourdomain.com`) to your server's IP address
   - Ensure ports 80 and 443 are open in your firewall

2. Configure production environment:
   ```bash
   cp .env.omeka.example .env.omeka
   nano .env.omeka  # Configure your domain and credentials
   ```

   Key settings to configure:
   ```env
   DOMAIN=omeka.yourdomain.com
   ACME_EMAIL=your-email@example.com  # For SSL certificate notifications
   ```

3. Run the setup script:
   ```bash
   ./setup-omeka-traefik.sh
   ```

4. Install modules and themes:
   ```bash
   ./install-modules.sh
   ```

5. Access your production site:
   - Omeka S: `https://omeka.yourdomain.com` (note: HTTPS!)
   - Traefik Dashboard: `https://traefik.yourdomain.com`

## Architecture

The stack consists of three main components:

- **Omeka S Application**: The main application container running PHP-FPM
- **MariaDB**: Database for storing your collections and metadata
- **Nginx**: Web server for serving the application

### Security Features

- Non-root user execution
- Read-only root filesystem where possible
- Secure environment variable handling
- Network isolation between services
- Regular security updates

## Module Management

One of the standout features is automated module management. The included scripts handle:

- Installing popular modules like ImageServer, CSVImport, and FileSideload
- Keeping modules updated to their latest versions
- Managing module dependencies

## Production Deployment Details

### Why Choose Traefik?

When deploying web applications to production, you need to handle several concerns:
- **SSL/TLS encryption** - Required for security and SEO
- **Certificate management** - Obtaining and renewing SSL certificates
- **Multiple services** - Running several applications on one server
- **Security headers** - Protecting against common web vulnerabilities

Traefik handles all of these automatically, saving you hours of configuration and maintenance.

### Production Environment Features

Our production setup includes:

- **Automatic SSL certificates** via Let's Encrypt
- **Health checks** to ensure services are running
- **Monitoring dashboard** to track service status
- **Backup strategies** for your data
- **Performance optimizations** for handling larger collections

### Security Considerations

The production setup implements several security best practices:
- Non-root container execution
- Network isolation between services
- Secure environment variable handling
- Regular security updates
- HTTPS-only access with HSTS headers

## Community and Support

We believe in the power of community collaboration. Whether you're:

- Reporting bugs
- Suggesting features
- Contributing code
- Sharing your use cases

Your input helps make Omeka S Docker better for everyone.

## What's Next?

We're continuously improving Omeka S Docker with:

- Enhanced monitoring capabilities
- Kubernetes deployment options
- Automated backup solutions
- Performance optimizations

## Get Involved

This project is open source and welcomes contributions from the community. Visit our GitHub repository to:

- 🐛 Report bugs and issues
- 💡 Suggest new features
- 🤝 Contribute code improvements
- ⭐ Star the project if you find it useful

**Repository**: [https://github.com/nakamura196/omeka-s-docker](https://github.com/nakamura196/omeka-s-docker)

Every contribution, no matter how small, is valued and appreciated.

## Conclusion

Omeka S Docker represents our commitment to making digital collection management accessible, secure, and efficient. Whether you're a small archive or a large institution, this solution scales to meet your needs while maintaining simplicity.

Start building your digital collections today with Omeka S Docker!

---

*For detailed documentation, visit our [GitHub repository](https://github.com/nakamura196/omeka-s-docker) or open an issue if you need help.*