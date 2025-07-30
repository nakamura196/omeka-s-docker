#!/bin/bash

echo "=== Omeka S Setup with External Traefik ==="

# .env.omekaファイルが存在しない場合は作成
if [ ! -f .env.omeka ]; then
    echo "Creating .env.omeka file..."
    cp .env.omeka.example .env.omeka
    
    echo "Environment file created. Please edit .env.omeka with your actual settings."
fi

# 設定の確認
echo ""
echo "⚠️  IMPORTANT: Please edit .env.omeka and configure the following:"
echo "   1. DOMAIN=your-omeka-domain.com (your actual domain)"
echo "   2. MYSQL_ROOT_PASSWORD=your-secure-password"
echo "   3. MYSQL_PASSWORD=your-secure-password"
echo "   4. Other settings as needed"
echo ""
echo "Note: This setup assumes you have an external Traefik instance running"
echo "with the 'traefik-network' already created."
echo ""
echo "Press Enter to continue with the current settings..."
read -r

# .envファイルをロード
export $(cat .env.omeka | grep -v '^#' | xargs)

# 必要なディレクトリを作成
echo "Creating necessary directories..."
mkdir -p config
mkdir -p modules
mkdir -p themes
mkdir -p traefik/letsencrypt
chmod 600 traefik/letsencrypt

# local.config.phpが存在しない場合は作成
if [ ! -f config/local.config.php ]; then
    echo "Creating local.config.php..."
    cat > config/local.config.php << 'EOF'
<?php
return [
    'database' => [
        'adapter' => 'PDO_MySQL',
        'driver_options' => [
            PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4',
        ],
        'database' => getenv('DB_NAME') ?: 'omeka',
        'username' => getenv('DB_USER') ?: 'omeka',
        'password' => getenv('DB_PASSWORD') ?: 'omeka',
        'hostname' => getenv('DB_HOST') ?: 'mariadb',
        'port' => getenv('DB_PORT') ?: '3306',
    ],
    'mail' => [
        'transport' => [
            'type' => 'smtp',
            'options' => [
                'name' => 'localhost',
                'host' => 'mailpit',
                'port' => 1025,
                'connection_class' => 'plain',
                'connection_config' => [
                    'username' => '',
                    'password' => '',
                ],
            ],
        ],
        'default_from' => getenv('MAIL_FROM_ADDRESS') ?: 'noreply@localhost',
        'default_from_name' => getenv('MAIL_FROM_NAME') ?: 'Omeka S',
    ],
    'logger' => [
        'log' => false,
    ],
];
EOF
    echo "local.config.php created!"
fi

# .htaccessが存在しない場合は作成
if [ ! -f .htaccess ]; then
    echo "Creating .htaccess..."
    cat > .htaccess << 'EOF'
RewriteEngine On

# Block access to all .txt files except robots.txt
RewriteRule ^(?!robots\.txt$).*\.txt$ - [F,L]

# Allow access to the error log
RewriteRule ^error_log$ - [F,L]

# Allow all other requests
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
EOF
    echo ".htaccess created!"
fi

# Dockerイメージをビルド
echo "Building Docker images..."
if ! docker compose -f docker-compose-omeka-traefik.yml build; then
    echo "❌ Docker build failed. Trying without cache..."
    docker compose -f docker-compose-omeka-traefik.yml build --no-cache
fi

# コンテナを起動
echo "Starting containers..."
docker compose -f docker-compose-omeka-traefik.yml up -d

# 起動確認
echo "Waiting for services to be ready..."
sleep 30

# データベースの初期化確認
echo "Checking database connection..."
docker compose -f docker-compose-omeka-traefik.yml exec mariadb mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SHOW DATABASES;" 2>/dev/null || echo "Database may still be initializing..."

# アプリケーションの状態確認
echo "Checking application status..."
if docker compose -f docker-compose-omeka-traefik.yml ps | grep -q "Up"; then
    echo "✅ Application containers are running!"
else
    echo "❌ Some containers may have issues. Check logs:"
    echo "  docker compose -f docker-compose-omeka-traefik.yml logs"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Services are available at:"
echo "  - Omeka S: https://${DOMAIN}"
echo "  - Traefik Dashboard: https://traefik.${DOMAIN} (admin/password)"
echo "  - PhpMyAdmin (localhost only): http://localhost:8080"
echo "  - Mailpit (localhost only): http://localhost:8025"
echo ""
echo "To access PhpMyAdmin or Mailpit from remote, use SSH tunnel:"
echo "  ssh -L 8080:localhost:8080 -L 8025:localhost:8025 user@server-ip"
echo ""
echo "Traefik Dashboard is also available locally at:"
echo "  http://localhost:8090"
echo ""
echo "To stop the application, run:"
echo "  docker compose -f docker-compose-omeka-traefik.yml down"
echo ""
echo "To view logs, run:"
echo "  docker compose -f docker-compose-omeka-traefik.yml logs -f"
echo ""
echo "📝 Next steps:"
echo "  1. Access https://${DOMAIN} to complete Omeka S installation"
echo "  2. Configure site settings through the web interface"
echo "  3. Monitor SSL certificate status via Traefik dashboard"