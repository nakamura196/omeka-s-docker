#!/bin/bash
set -e

# 環境変数を使用してPHP設定を生成
envsubst < /usr/local/etc/php/conf.d/custom.ini.template > /usr/local/etc/php/conf.d/custom.ini

# SendGrid設定がある場合、local.config.phpを更新
if [ ! -z "$SENDGRID_API_KEY" ]; then
    echo "Configuring SendGrid..."
    # ここでOmeka Sの設定ファイルを更新するロジックを追加
fi

# 元のコマンドを実行
exec "$@"