# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |
| < latest| :x:                |

## Reporting a Vulnerability

We take the security of Omeka S Docker seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Please do the following:

- **Do not** open a public issue
- Email your findings to security@yourdomain.com
- Include the following details:
  - Description of the vulnerability
  - Steps to reproduce the issue
  - Potential impact
  - Suggested fix (if any)

### What to expect:

- Acknowledgment of your report within 48 hours
- Assessment of the vulnerability severity
- Regular updates on our progress
- Credit for responsible disclosure (if desired)

## Security Best Practices

When using Omeka S Docker, we recommend:

### Environment Variables
- Never commit `.env` files to version control
- Use strong, unique passwords
- Rotate credentials regularly

### Docker Security
- Keep Docker and Docker Compose updated
- Run containers with non-root users (already configured)
- Limit container capabilities
- Use read-only filesystems where possible

### Network Security
- Use HTTPS in production (Traefik setup included)
- Implement firewall rules
- Limit exposed ports
- Use Docker networks for service isolation

### Database Security
- Use strong MariaDB passwords
- Limit database user privileges
- Regular backups
- Encrypt sensitive data

### File Permissions
- Ensure proper ownership of volumes
- Restrict file permissions
- Regular security audits

## Security Updates

We regularly update our base images and dependencies to include the latest security patches. To stay secure:

1. Watch this repository for updates
2. Pull latest changes regularly
3. Rebuild images after updates
4. Monitor security advisories for:
   - Omeka S
   - PHP
   - MariaDB
   - Nginx
   - Docker base images

## Additional Resources

- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [OWASP Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Omeka S Security](https://omeka.org/s/docs/user-manual/admin/security/)

Thank you for helping keep Omeka S Docker secure!