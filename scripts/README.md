# Omeka S API Scripts

This directory contains utility scripts for managing Omeka S via its REST API.

## Bulk User Management Script

The `bulk_create_users.py` script allows you to create or delete multiple users in Omeka S from a CSV file.

### Prerequisites

1. Python 3.6 or higher
2. Required Python packages:
   ```bash
   pip install requests python-dotenv
   ```

3. Omeka S API credentials:
   - You need API keys from your Omeka S installation
   - Go to your Omeka S admin panel → Users → Your Profile → API keys
   - Create a new API key and save the identity and credential

### Configuration

The script supports three ways to provide API credentials:

1. **Environment file (.env)** - Recommended for regular use:
   ```bash
   cp scripts/.env.example scripts/.env
   # Edit scripts/.env with your credentials
   ```

2. **Command line arguments** - Good for one-time use:
   ```bash
   python bulk_create_users.py --key-identity YOUR_KEY --key-credential YOUR_CREDENTIAL
   ```

3. **Interactive prompts** - Script will ask for credentials if not provided

### Usage

#### Creating Users

```bash
# Basic usage (default mode is create)
python bulk_create_users.py -u https://your-omeka-site.com -f users.csv

# With .env file configuration
python bulk_create_users.py -f users.csv

# With explicit API credentials
python bulk_create_users.py \
  -u https://your-omeka-site.com \
  -f users.csv \
  --key-identity YOUR_API_KEY_IDENTITY \
  --key-credential YOUR_API_KEY_CREDENTIAL
```

#### Deleting Users

```bash
# Delete users specified in CSV
python bulk_create_users.py -u https://your-omeka-site.com -f users_to_delete.csv --mode delete

# With .env file configuration
python bulk_create_users.py -f users_to_delete.csv --mode delete
```

### File Formats

#### CSV Format for Creating Users (example_users.csv)
```csv
email,name,role,is_active,password
john@example.com,John Doe,researcher,true,ChangeMeNow123!
jane@example.com,Jane Smith,author,true,SecurePass456!
admin@example.com,Admin User,admin,true,AdminPass789!
```

#### CSV Format for Deleting Users (example_users_to_delete.csv)
```csv
email
john@example.com
jane@example.com
admin@example.com
```

**Important Notes**:
- For creation: All users must have a password in the CSV file
- For deletion: Only email addresses are required
- Deletion is permanent and cannot be undone
- Use strong passwords for production environments
- Change example passwords immediately after creation

### User Roles in Omeka S

Available roles:
- `researcher`: Can search and read all resources
- `author`: Can add/edit own resources
- `reviewer`: Can add/edit all resources
- `editor`: Can add/edit/delete all resources
- `site_admin`: Can administer sites
- `admin`: Full administrative access

### Features

- **Bulk Operations**: Create or delete multiple users in one operation
- **Duplicate Detection**: Automatically skips users that already exist (create mode)
- **Error Handling**: Continues processing even if some operations fail
- **Progress Feedback**: Shows status for each operation
- **Results Summary**: Displays and saves detailed results
- **Secure Input**: Prompts for API credentials if not provided
- **Safety Confirmation**: Requires explicit confirmation before deletion

### Output

The script creates a results file containing:
- For creation: `filename_create_results.json`
  - Successfully created users
  - Skipped users (already exist)
  - Failed users with error messages
- For deletion: `filename_delete_results.json`
  - Successfully deleted users
  - Users not found
  - Failed deletions with error messages

### Example Run

```bash
$ python bulk_create_users.py -u https://omeka.example.com -f users.csv
Enter API key identity: your_key_identity
Enter API key credential: 
Testing connection to https://omeka.example.com...
Connection successful!
Loaded 6 users from users.csv
Proceed with creating 6 users? (y/N): y

Creating users...
Created user: researcher1@example.com
Created user: author1@example.com
Skipping admin@example.com: User already exists
Created user: editor1@example.com
Created user: viewer1@example.com
Created user: contributor1@example.com

==================================================
SUMMARY
==================================================
Successfully created: 5
Skipped (already exist): 1
Failed: 0

Detailed results saved to: users_results.json
```

### Troubleshooting

1. **Connection Failed**: 
   - Verify the Omeka S URL is correct
   - Check that API is enabled in Omeka S
   - Ensure API credentials are valid

2. **User Creation Failed**:
   - Check user role is valid
   - Ensure email addresses are unique
   - Verify email format is correct

3. **Permission Denied**:
   - API key needs permission to create users
   - Contact your Omeka S administrator

## Japanese Documentation / 日本語ドキュメント

### Omeka S ユーザー一括管理スクリプト

`bulk_create_users.py` は、CSV ファイルから Omeka S に複数のユーザーを一括作成または削除するスクリプトです。

### 必要条件

1. Python 3.6 以上
2. 必要な Python パッケージのインストール：
   ```bash
   pip install requests python-dotenv
   ```

3. Omeka S API 認証情報：
   - Omeka S 管理画面 → ユーザー → プロフィール → API キー
   - 新しい API キーを作成し、ID と認証情報を保存

### 設定方法

API認証情報を提供する3つの方法があります：

1. **環境ファイル (.env)** - 通常使用に推奨：
   ```bash
   cp scripts/.env.example scripts/.env
   # scripts/.env を編集して認証情報を設定
   ```

2. **コマンドライン引数** - 一時的な使用に便利
3. **対話型プロンプト** - 未提供の場合は自動的に質問

### 使用方法

#### ユーザーの作成

```bash
# 基本的な使用方法（デフォルトは作成モード）
python bulk_create_users.py -u https://omeka.example.com -f users.csv

# .env ファイルの設定を使用
python bulk_create_users.py -f users.csv

# API認証情報を明示的に指定
python bulk_create_users.py \
  -u https://omeka.example.com \
  -f users.csv \
  --key-identity API_KEY_ID \
  --key-credential API_KEY_CREDENTIAL
```

#### ユーザーの削除

```bash
# CSV に指定されたユーザーを削除
python bulk_create_users.py -u https://omeka.example.com -f users_to_delete.csv --mode delete

# .env ファイルの設定を使用
python bulk_create_users.py -f users_to_delete.csv --mode delete
```

### ファイル形式

#### ユーザー作成用 CSV（example_users.csv）
```csv
email,name,role,is_active,password
taro@example.com,田中太郎,researcher,true,ChangeMe123!
hanako@example.com,山田花子,author,true,ChangeMe456!
```

#### ユーザー削除用 CSV（example_users_to_delete.csv）
```csv
email
taro@example.com
hanako@example.com
```

**重要な注意事項**：
- 作成時：すべてのユーザーにパスワードが必要です
- 削除時：メールアドレスのみ必要です
- 削除は永久的で元に戻せません
- 本番環境では強力なパスワードを使用してください
- 作成後は速やかにパスワードを変更してください

### 機能

- 一括操作：一度に複数のユーザーを作成または削除
- 重複検出：既存ユーザーの自動スキップ（作成モード）
- エラー処理：一部の操作が失敗しても処理を継続
- 進捗表示：各操作の状態を表示
- 結果サマリー：詳細な結果を表示・保存
- セキュアな入力：未提供時は認証情報を対話的に要求
- 安全確認：削除前に明示的な確認を要求

### 出力

処理結果は以下のファイルとして保存されます：
- 作成時：`ファイル名_create_results.json`
  - 正常に作成されたユーザー
  - スキップされたユーザー（既存）
  - 失敗したユーザーとエラーメッセージ
- 削除時：`ファイル名_delete_results.json`
  - 正常に削除されたユーザー
  - 見つからなかったユーザー
  - 削除に失敗したユーザーとエラーメッセージ