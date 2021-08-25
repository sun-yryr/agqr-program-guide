# agqr-program-guide

[超A&G+の番組表](https://www.joqr.co.jp/qr/agdailyprogram/) から番組情報・出演者を取得し、JSON形式のREST APIとして提供しています。

https://agqr.sun-yryr.com で提供中です。

フレームワークとしてSwift製のVaporを利用しています。

## Development

前提
```bash
swift --version
# 5.4.2
vapor --version
# framework: 4.45.0
# toolbox: 18.3.3
```

1. DBとRedisを起動する。 `make up`
1. 開発する。
1. サーバーを立てて動作確認する。 `make serve`

### lint

swiftlintかswift-formatを利用する予定。更新する。

### build & push

GitHub Actionsのページから `build-push` のワークフローを実行する。

### deploy

1. EC2にログインする。
1. pushしたDockerImageをPullしてくる。（直接起動する場合は飛ばしてもいい）
1. 環境変数とかを設定して起動する。下記の「使う」を参考にする。

## 使う

適宜タグや環境変数の変更が必要。

### マイグレーション
```bash
docker run --rm -e DATABASE_HOST=127.0.0.1 -e REDIS_URL="redis://127.0.0.1:6379" ghcr.io/sun-yryr/agqr-program-guide:latest migrate --yes
```

### 手動スクレイピング

基本的に自動で取ってくるので必要ない。初回起動などで利用する。  
※ hoge は使っていない引数なので後々削除する。
```bash
docker run --rm -e DATABASE_HOST=127.0.0.1 -e REDIS_URL="redis://127.0.0.1:6379" -e TZ=Asia/Tokyo ghcr.io/sun-yryr/agqr-program-guide:latest scraping hoge
```

### 起動
```bash
docker run -d -e DATABASE_HOST=127.0.0.1 -e REDIS_URL="redis://127.0.0.1:6379" -e TZ=Asia/Tokyo -p 3000:8080 ghcr.io/sun-yryr/agqr-program-guide:latest
```

## ライセンス

そのうち
