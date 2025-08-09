# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリでコード作業を行う際の指針を提供します。

## プロジェクト構造

```
docker-example/
├── docker/                 # Docker設定ファイル
│   ├── nginx/
│   │   └── nginx.conf
│   ├── php/
│   │   ├── Dockerfile
│   │   └── php.ini
│   ├── phpmyadmin/
│   │   └── config.inc.php
│   └── mysql/
├── src/                    # PHPアプリケーションファイル
├── db-data/                # MySQL永続データ
├── docker-compose.yml      # Docker Compose設定
└── Makefile               # 便利コマンド集
```

## アーキテクチャ概要

これは以下のスタックを持つDockerベースのPHP開発環境です：
- **Nginx**: PHP-FPMへのプロキシWebサーバー（ポート80）
- **PHP 8.3-FPM**: Composer、Xdebugサポート付きカスタムイメージ（デバッグポート9003）
- **MySQL 8.0**: データベースサーバー（ポート3306）
- **phpMyAdmin**: データベース管理インターフェース（ポート8080）

すべてのサービスはDockerネットワーク `app-network` 経由で通信します。PHPファイルは `src/` ディレクトリに保存され、Nginxによって配信されます。

## よく使用するコマンド

### Makefile（推奨）
```bash
# 基本操作
make up              # すべてのサービスを起動
make down            # すべてのサービスを停止
make build           # イメージをビルドして起動
make rebuild         # キャッシュなしで再ビルド
make restart         # サービスを再起動
make status          # サービスの状態を確認

# 開発作業
make shell           # PHPコンテナにシェルでログイン
make composer        # Composerヘルプを表示
make composer CMD=install         # composer install実行
make composer CMD="require monolog/monolog"  # パッケージ追加

# データベース
make mysql           # MySQLクライアント接続
make phpmyadmin      # phpMyAdminのURL表示

# その他
make logs            # 全サービスのログ表示
make logs SERVICE=php    # 特定サービスのログ表示
make clean           # 環境をクリーンアップ
make info            # 開発環境の詳細情報表示
make help            # 利用可能コマンド一覧
```

### Docker Compose（直接使用）
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

### Composer
- **インストール済み**: PHP 8.3コンテナにComposer 2.8.10がプリインストール
- **パッケージ管理**: `make composer CMD="require パッケージ名"` で依存関係を追加
- **autoload**: `make composer CMD="dump-autoload"` でオートローダー更新

### カスタムイメージ
- **PHPコンテナ**: `docker/php/Dockerfile` からビルド、Composer、Xdebugと必須拡張機能付き（GD, PDO, MySQLi）
- **設定ファイル**: カスタム `docker/php/php.ini` を `/usr/local/etc/php/conf.d/custom.ini` にマウント

### ボリュームマウント
- `src/` → `/var/www/html` （PHPファイル）
- `db-data/` → `/var/lib/mysql` （永続データベース保存）
- `docker/nginx/nginx.conf` → `/etc/nginx/nginx.conf` （Nginx設定）
- `docker/php/php.ini` → `/usr/local/etc/php/conf.d/custom.ini` （PHP設定）
- `docker/phpmyadmin/config.inc.php` → `/etc/phpmyadmin/config.inc.php` （phpMyAdmin設定）

## デバッグ設定

Xdebugは事前にインストール・設定済みです。IDE設定：
1. デバッグポートを9003に設定
2. パスマッピングを設定: `/var/www/html` → `./src`
3. IDE key `PHPSTORM` を使用
4. `host.docker.internal` がコンテナからアクセス可能であることを確認