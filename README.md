# agqr-program-guide

[超A&G+の番組表](https://www.joqr.co.jp/qr/agdailyprogram/) から番組情報・出演者を取得し、JSON 形式の REST API として提供しています。

https://agqr.sun-yryr.com で提供中です。

フレームワークとして [Vapor](https://github.com/vapor/vapor) を利用しています。

## PostgreSQL SSL接続の設定

本番環境およびローカル開発環境でPostgreSQLへのSSL接続を有効にするための手順です。

### 1. 自己署名証明書の生成

ローカル開発環境では、以下のコマンドで自己署名証明書を生成します：

```bash
# 証明書用のディレクトリを作成
mkdir -p docker/db/certs

# 秘密鍵の生成
openssl genrsa -out docker/db/certs/server.key 2048

# 証明書署名要求(CSR)の生成
openssl req -new -key docker/db/certs/server.key -out docker/db/certs/server.csr -subj "/CN=localhost"

# 自己署名証明書の生成
openssl x509 -req -in docker/db/certs/server.csr -signkey docker/db/certs/server.key -out docker/db/certs/server.crt -days 365

# 権限の設定
chmod 600 docker/db/certs/server.key
```

**注意**: 生成された証明書ファイルはGitリポジトリに含めないでください。

### 3. 環境変数の設定

`.env`ファイルに以下の環境変数を追加します：

```
DATABASE_USE_SSL=true
```

本番環境では、適切な証明書検証設定が自動的に有効になります。開発環境では証明書検証が自動的に無効化されます。
