# Omeka S Docker

🐳 A modern Docker setup for [Omeka S](https://omeka.org/s/) with IIIF support, SSL/TLS encryption, and development tools.

## ✨ Features

- **Modern Stack**: PHP 8.1, Apache, MariaDB
- **IIIF Support**: Pre-configured IIIF Server, Image Server, and Universal Viewer modules
- **SSL/TLS**: Automatic HTTPS with Let's Encrypt via Traefik
- **Development Tools**: 
  - Mailpit for email testing
  - phpMyAdmin for database management
  - Hot-reload for modules and themes
- **Production Ready**: Optimized for production deployment
- **Security**: Environment-based configuration with secure defaults

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose installed
- Domain name (for production with SSL)

### Development Setup

1. **Clone and setup environment**
```bash
git clone https://github.com/nakamura196/omeka-s-docker.git
cd omeka-s-docker
cp .env.example .env
```

2. **Configure environment variables**
```bash
nano .env  # Edit with your settings
```

3. **Start services**
```bash
docker compose up -d
```

4. **Access services**
- Omeka S: http://localhost
- phpMyAdmin: http://localhost:8080
- Mailpit: http://localhost:8025

### Production Setup with SSL

1. **Setup environment for production**
```bash
cp .env.omeka.example .env.omeka
nano .env.omeka  # Configure your domain and credentials
```

2. **Run setup script**
```bash
./setup-omeka-traefik.sh
```

3. **Install modules and themes**
```bash
./install-modules.sh
```

## 📦 Services

| Service | Description | Port | URL |
|---------|-------------|------|-----|
| **Omeka S** | Main application | 80/443 | http://localhost or https://yourdomain.com |
| **MariaDB** | Database | 3306 | Internal only |
| **phpMyAdmin** | Database management | 8080 | http://localhost:8080 |
| **Mailpit** | Email testing | 8025 | http://localhost:8025 |
| **Traefik** | Reverse proxy & SSL | 8090 | http://localhost:8090 (dashboard) |

## 🔧 Configuration

### Environment Variables

#### Development (.env)
```env
# Database
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=omeka
MYSQL_USER=omeka
MYSQL_PASSWORD=your_secure_password

# Omeka
OMEKA_VERSION=4.1.1

# PHP Settings
PHP_MEMORY_LIMIT=256M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M

# Mail (leave empty for Mailpit)
SENDGRID_API_KEY=
MAIL_FROM_ADDRESS=noreply@localhost
MAIL_FROM_NAME=Omeka S
```

#### Production (.env.omeka)
```env
# Domain Configuration
DOMAIN=yourdomain.com
ACME_EMAIL=admin@yourdomain.com

# Database (use strong passwords)
MYSQL_ROOT_PASSWORD=very_secure_root_password
MYSQL_DATABASE=omeka_production
MYSQL_USER=omeka_user
MYSQL_PASSWORD=very_secure_password

# SendGrid for production email
SENDGRID_API_KEY=SG.your_actual_api_key_here
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME=Your Omeka Site
```

## 📚 Modules & Themes

### Included Modules
- **Common**: Base module for other extensions
- **IiifServer**: IIIF Image and Presentation API server
- **ImageServer**: Image processing and serving
- **UniversalViewer**: IIIF-compliant viewer

### Module Management

**Install/Update modules:**
```bash
./install-modules.sh
```

**Check for updates:**
```bash
./update-modules.sh
```

**Manual installation:**
```bash
cd modules
wget https://github.com/author/module/releases/download/version/module.zip
unzip module.zip && rm module.zip
```

## 🛠️ Management Commands

### Container Management
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f

# Restart specific service
docker compose restart omeka

# Shell access
docker compose exec omeka bash
```

### Database Operations
```bash
# Database backup
docker compose exec mariadb mysqldump -u root -p omeka > backup.sql

# Database restore
docker compose exec -i mariadb mysql -u root -p omeka < backup.sql

# Access MySQL CLI
docker compose exec mariadb mysql -u root -p
```

### SSL/Production Management
```bash
# Production setup
./setup-omeka-traefik.sh

# Check SSL certificates
docker compose -f docker-compose-omeka-traefik.yml logs traefik

# View Traefik dashboard
# https://traefik.yourdomain.com (or http://localhost:8090)
```

## 🔒 Security

### Best Practices
- ✅ Use strong, unique passwords for all services
- ✅ Keep environment files (`.env*`) out of version control
- ✅ Use HTTPS in production
- ✅ Regularly update Docker images and modules
- ✅ Limit SendGrid API key permissions to `mail.send` only
- ✅ Use firewall rules to restrict database access

### Security Headers
The Traefik configuration includes security headers:
- HSTS (HTTP Strict Transport Security)
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Referrer Policy: strict-origin-when-cross-origin

## 📁 Directory Structure

```
omeka-s-docker/
├── docker-compose.yml              # Development setup
├── docker-compose-omeka-traefik.yml # Production setup with SSL
├── Dockerfile                      # Omeka S image definition
├── .env.example                   # Development environment template
├── .env.omeka.example            # Production environment template
├── install-modules.sh            # Module installation script
├── update-modules.sh             # Module update checker
├── setup-omeka-traefik.sh       # Production setup script
├── config/
│   └── local.config.php          # Omeka S configuration
├── modules/                      # Omeka S modules
├── themes/                       # Omeka S themes
└── traefik/
    └── letsencrypt/             # SSL certificates
```

## 🔍 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check logs
docker compose logs service-name

# Rebuild without cache
docker compose build --no-cache
```

**Database connection issues:**
```bash
# Verify database is running
docker compose ps
docker compose logs mariadb

# Test connection
docker compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

**SSL certificate issues:**
```bash
# Check Traefik logs
docker compose -f docker-compose-omeka-traefik.yml logs traefik

# Verify domain DNS
nslookup yourdomain.com

# Check certificate status
curl -I https://yourdomain.com
```

**Permission issues:**
```bash
# Fix file permissions
docker compose exec omeka chown -R www-data:www-data /var/www/html/
docker compose exec omeka chmod -R 755 /var/www/html/modules /var/www/html/themes
```

### Performance Tuning

**Increase PHP limits:**
```env
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_MAX_FILESIZE=200M
PHP_POST_MAX_SIZE=200M
```

**Database optimization:**
```bash
# Add to .env for larger installations
MYSQL_INNODB_BUFFER_POOL_SIZE=1G
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Omeka S](https://omeka.org/s/) - Digital publishing platform
- [Daniel-KM](https://github.com/Daniel-KM) - IIIF modules developer
- [Traefik](https://traefik.io/) - Modern reverse proxy
- [Docker](https://docker.com/) - Containerization platform

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/nakamura196/omeka-s-docker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nakamura196/omeka-s-docker/discussions)
- **Omeka S Documentation**: [https://omeka.org/s/docs/](https://omeka.org/s/docs/)

---

**Made with ❤️ for the digital humanities community**

---

# Omeka S Docker（日本語）

🐳 [Omeka S](https://omeka.org/s/) のための現代的なDocker環境。IIIF対応、SSL/TLS暗号化、開発ツールを含みます。

## ✨ 機能

- **現代的なスタック**: PHP 8.1、Apache、MariaDB
- **IIIF対応**: IIIF Server、Image Server、Universal Viewerモジュールを事前設定
- **SSL/TLS**: TraefikによるLet's Encryptを使った自動HTTPS
- **開発ツール**:
  - メールテスト用Mailpit
  - データベース管理用phpMyAdmin
  - モジュールとテーマのホットリロード
- **本番対応**: 本番デプロイメント向けに最適化
- **セキュリティ**: 環境ベース設定とセキュアなデフォルト値

## 🚀 クイックスタート

### 前提条件

- DockerとDocker Composeがインストール済み
- ドメイン名（SSL付き本番環境用）

### 開発環境セットアップ

1. **クローンと環境設定**
```bash
git clone https://github.com/nakamura196/omeka-s-docker.git
cd omeka-s-docker
cp .env.example .env
```

2. **環境変数の設定**
```bash
nano .env  # 設定値を編集
```

3. **サービス開始**
```bash
docker compose up -d
```

4. **サービスへのアクセス**
- Omeka S: http://localhost
- phpMyAdmin: http://localhost:8080
- Mailpit: http://localhost:8025

### SSL付き本番環境セットアップ

1. **本番環境用設定**
```bash
cp .env.omeka.example .env.omeka
nano .env.omeka  # ドメインと認証情報を設定
```

2. **セットアップスクリプト実行**
```bash
./setup-omeka-traefik.sh
```

3. **モジュールとテーマのインストール**
```bash
./install-modules.sh
```

## 📦 サービス

| サービス | 説明 | ポート | URL |
|----------|------|-------|-----|
| **Omeka S** | メインアプリケーション | 80/443 | http://localhost または https://yourdomain.com |
| **MariaDB** | データベース | 3306 | 内部のみ |
| **phpMyAdmin** | データベース管理 | 8080 | http://localhost:8080 |
| **Mailpit** | メールテスト | 8025 | http://localhost:8025 |
| **Traefik** | リバースプロキシ & SSL | 8090 | http://localhost:8090 (ダッシュボード) |

## 🔧 設定

### 環境変数

#### 開発環境 (.env)
```env
# データベース
MYSQL_ROOT_PASSWORD=安全なルートパスワード
MYSQL_DATABASE=omeka
MYSQL_USER=omeka
MYSQL_PASSWORD=安全なパスワード

# Omeka
OMEKA_VERSION=4.1.1

# PHP設定
PHP_MEMORY_LIMIT=256M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M

# メール（Mailpit使用時は空のまま）
SENDGRID_API_KEY=
MAIL_FROM_ADDRESS=noreply@localhost
MAIL_FROM_NAME=Omeka S
```

#### 本番環境 (.env.omeka)
```env
# ドメイン設定
DOMAIN=yourdomain.com
ACME_EMAIL=admin@yourdomain.com

# データベース（強力なパスワードを使用）
MYSQL_ROOT_PASSWORD=非常に安全なルートパスワード
MYSQL_DATABASE=omeka_production
MYSQL_USER=omeka_user
MYSQL_PASSWORD=非常に安全なパスワード

# 本番環境用SendGrid
SENDGRID_API_KEY=SG.実際のAPIキー
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME=あなたのOmekaサイト
```

## 📚 モジュール & テーマ

### 含まれるモジュール
- **Common**: 他の拡張機能のベースモジュール
- **IiifServer**: IIIF画像とプレゼンテーションAPIサーバー
- **ImageServer**: 画像処理と配信
- **UniversalViewer**: IIIF準拠ビューアー

### モジュール管理

**モジュールのインストール/更新:**
```bash
./install-modules.sh
```

**更新確認:**
```bash
./update-modules.sh
```

**手動インストール:**
```bash
cd modules
wget https://github.com/作者/モジュール/releases/download/バージョン/モジュール.zip
unzip モジュール.zip && rm モジュール.zip
```

## 🛠️ 管理コマンド

### コンテナ管理
```bash
# サービス開始
docker compose up -d

# サービス停止
docker compose down

# ログ確認
docker compose logs -f

# 特定サービスの再起動
docker compose restart omeka

# シェルアクセス
docker compose exec omeka bash
```

### データベース操作
```bash
# データベースバックアップ
docker compose exec mariadb mysqldump -u root -p omeka > backup.sql

# データベース復元
docker compose exec -i mariadb mysql -u root -p omeka < backup.sql

# MySQL CLI アクセス
docker compose exec mariadb mysql -u root -p
```

### SSL/本番環境管理
```bash
# 本番環境セットアップ
./setup-omeka-traefik.sh

# SSL証明書確認
docker compose -f docker-compose-omeka-traefik.yml logs traefik

# Traefikダッシュボード確認
# https://traefik.yourdomain.com（または http://localhost:8090）
```

## 🔒 セキュリティ

### ベストプラクティス
- ✅ 全サービスに強力でユニークなパスワードを使用
- ✅ 環境ファイル（`.env*`）をバージョン管理から除外
- ✅ 本番環境でHTTPSを使用
- ✅ Dockerイメージとモジュールを定期的に更新
- ✅ SendGrid APIキーの権限を`mail.send`のみに制限
- ✅ ファイアウォールルールでデータベースアクセスを制限

### セキュリティヘッダー
Traefik設定にはセキュリティヘッダーが含まれます：
- HSTS（HTTP Strict Transport Security）
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Referrer Policy: strict-origin-when-cross-origin

## 📁 ディレクトリ構造

```
omeka-s-docker/
├── docker-compose.yml              # 開発環境設定
├── docker-compose-omeka-traefik.yml # SSL付き本番環境設定
├── Dockerfile                      # Omeka Sイメージ定義
├── .env.example                   # 開発環境テンプレート
├── .env.omeka.example            # 本番環境テンプレート
├── install-modules.sh            # モジュールインストールスクリプト
├── update-modules.sh             # モジュール更新チェッカー
├── setup-omeka-traefik.sh       # 本番環境セットアップスクリプト
├── config/
│   └── local.config.php          # Omeka S設定
├── modules/                      # Omeka Sモジュール
├── themes/                       # Omeka Sテーマ
└── traefik/
    └── letsencrypt/             # SSL証明書
```

## 🔍 トラブルシューティング

### よくある問題

**コンテナが起動しない:**
```bash
# ログ確認
docker compose logs サービス名

# キャッシュなしで再ビルド
docker compose build --no-cache
```

**データベース接続エラー:**
```bash
# データベースの動作確認
docker compose ps
docker compose logs mariadb

# 接続テスト
docker compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"
```

**SSL証明書の問題:**
```bash
# Traefikログ確認
docker compose -f docker-compose-omeka-traefik.yml logs traefik

# ドメインDNS確認
nslookup yourdomain.com

# 証明書ステータス確認
curl -I https://yourdomain.com
```

**権限の問題:**
```bash
# ファイル権限修正
docker compose exec omeka chown -R www-data:www-data /var/www/html/
docker compose exec omeka chmod -R 755 /var/www/html/modules /var/www/html/themes
```

### パフォーマンスチューニング

**PHP制限の増加:**
```env
PHP_MEMORY_LIMIT=512M
PHP_UPLOAD_MAX_FILESIZE=200M
PHP_POST_MAX_SIZE=200M
```

**データベース最適化:**
```bash
# 大規模インストールの場合は.envに追加
MYSQL_INNODB_BUFFER_POOL_SIZE=1G
```

## 🤝 コントリビューション

1. リポジトリをフォーク
2. フィーチャーブランチを作成
3. 変更を実装
4. 十分にテスト
5. プルリクエストを提出

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- [Omeka S](https://omeka.org/s/) - デジタル出版プラットフォーム
- [Daniel-KM](https://github.com/Daniel-KM) - IIIFモジュール開発者
- [Traefik](https://traefik.io/) - 現代的なリバースプロキシ
- [Docker](https://docker.com/) - コンテナ化プラットフォーム

## 📞 サポート

- **問題報告**: [GitHub Issues](https://github.com/nakamura196/omeka-s-docker/issues)
- **ディスカッション**: [GitHub Discussions](https://github.com/nakamura196/omeka-s-docker/discussions)
- **Omeka Sドキュメント**: [https://omeka.org/s/docs/](https://omeka.org/s/docs/)

---

**デジタルヒューマニティーズコミュニティのために ❤️ を込めて作成**