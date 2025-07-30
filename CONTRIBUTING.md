# Contributing to Omeka S Docker

Thank you for your interest in contributing to Omeka S Docker! This project aims to provide a modern, secure, and easy-to-use Docker setup for Omeka S.

## How to Contribute

### Reporting Issues

- Check if the issue already exists in the [issue tracker](https://github.com/yourusername/omeka-s-docker/issues)
- Create a new issue with a clear title and detailed description
- Include steps to reproduce the problem
- Mention your environment (OS, Docker version, etc.)

### Submitting Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with descriptive messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/omeka-s-docker.git
   cd omeka-s-docker
   ```

2. Set up your environment:
   ```bash
   cp .env.example .env
   # Edit .env with your settings
   ```

3. Run the development environment:
   ```bash
   docker-compose up -d
   ```

### Coding Standards

- Follow existing code style and conventions
- Keep Docker images minimal and secure
- Document any new environment variables
- Test your changes in both development and production modes

### Testing

Before submitting a PR, ensure:
- Docker images build successfully
- Services start without errors
- Omeka S installation completes
- Basic functionality works (login, create items, etc.)

### Documentation

- Update README.md if you change setup procedures
- Document new features or configurations
- Add comments to complex Docker configurations

## Code of Conduct

Please note that this project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Questions?

Feel free to open an issue for any questions about contributing.

Thank you for helping make Omeka S Docker better!