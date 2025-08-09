# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリでコード作業を行う際の指針を提供します。

## アーキテクチャ概要

これは以下のスタックを持つDockerベースのPHP開発環境です：
- **Nginx**: PHP-FPMへのプロキシWebサーバー（ポート80）
- **PHP 8.3-FPM**: Xdebugサポート付きカスタムイメージ（デバッグポート9003）
- **MySQL 8.0**: データベースサーバー（ポート3306）
- **phpMyAdmin**: データベース管理インターフェース（ポート8080）

すべてのサービスはDockerネットワーク `app-network` 経由で通信します。PHPファイルは `src/` ディレクトリに保存され、Nginxによって配信されます。

## よく使用するコマンド

### 環境管理
```bash
# すべてのサービスを起動
docker-compose up -d

# ビルドして起動（Dockerfile変更後に必要）
docker-compose up --build -d

# すべてのサービスを停止
docker-compose down

# ログを表示
docker-compose logs [サービス名]

# 特定のサービスを再起動
docker-compose restart [サービス名]
```

### データベースアクセス
- **Webインターフェース**: http://localhost:8080 (phpMyAdmin)
- **直接接続**: localhost:3306
  - データベース: `testdb`
  - ユーザー: `testuser` / パスワード: `testpassword`
  - Root: `root` / パスワード: `rootpassword`

### 開発アクセス
- **ウェブサイト**: http://localhost
- **Xdebug**: ポート9003（IDE Key: PHPSTORM）

## 設定詳細

### PHP設定
- **大容量ファイルアップロード**: 20GBアップロード対応（`upload_max_filesize`, `post_max_size`）
- **実行時間延長**: 大容量操作用に3600秒タイムアウト
- **Xdebug**: `host.docker.internal` 接続で事前設定済み

### カスタムイメージ
- **PHPコンテナ**: `php/Dockerfile` からビルド、Xdebugと必須拡張機能付き（GD, PDO, MySQLi）
- **設定ファイル**: カスタム `php.ini` を `/usr/local/etc/php/conf.d/custom.ini` にマウント

### ボリュームマウント
- `src/` → `/var/www/html` （PHPファイル）
- `db-data/` → `/var/lib/mysql` （永続データベース保存）
- 必要に応じて設定ファイルをマウント

## デバッグ設定

Xdebugは事前にインストール・設定済みです。IDE設定：
1. デバッグポートを9003に設定
2. パスマッピングを設定: `/var/www/html` → `./src`
3. IDE key `PHPSTORM` を使用
4. `host.docker.internal` がコンテナからアクセス可能であることを確認