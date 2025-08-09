# Docker PHP開発環境

Nginx、PHP、MySQL、phpMyAdminを組み合わせたDockerベースのPHP開発環境です。
Composer、大容量ファイルアップロード対応とXdebugによるデバッグ機能を備えています。

## 構成

- **Nginx**: Webサーバー（ポート80）
- **PHP 8.3-FPM**: Composer、Xdebug付きカスタムイメージ（デバッグポート9003）
- **MySQL 8.0**: データベースサーバー（ポート3306）
- **phpMyAdmin**: データベース管理ツール（ポート8080）

## 必要条件

- Docker
- Docker Compose
- Make（推奨）

## セットアップ

### 1. リポジトリのクローン

```bash
git clone <このリポジトリのURL>
cd docker-example
```

### 2. 環境の起動

#### Makeを使用（推奨）

```bash
# 初回起動（イメージビルドを含む）
make build

# 通常の起動
make up
```

#### Docker Composeを直接使用

```bash
# 初回起動（イメージビルドを含む）
docker-compose up --build -d

# 通常の起動
docker-compose up -d
```

### 3. 動作確認

- **Webサイト**: http://localhost
- **phpMyAdmin**: http://localhost:8080

## 使い方

### 基本操作

#### Make（推奨）

```bash
# 環境を起動
make up

# 環境を停止
make down

# 環境の状態確認
make status

# ログを確認
make logs

# 特定のサービスのログを確認
make logs SERVICE=php

# サービスを再起動
make restart

# PHPコンテナにログイン
make shell

# 環境をクリーンアップ
make clean

# ヘルプを表示
make help
```

#### Docker Compose

```bash
# 環境を起動
docker-compose up -d

# 環境を停止
docker-compose down

# ログを確認
docker-compose logs

# 特定のサービスのログを確認
docker-compose logs nginx
docker-compose logs php
docker-compose logs mysql
docker-compose logs phpmyadmin

# サービスを再起動
docker-compose restart php
```

### Composer

PHPパッケージ管理ツールComposerが利用できます：

```bash
# Composerヘルプを表示
make composer

# composer.jsonを作成
make composer CMD=init

# パッケージをインストール
make composer CMD=install

# パッケージを追加
make composer CMD="require monolog/monolog"

# 開発用パッケージを追加
make composer CMD="require --dev phpunit/phpunit"

# オートローダーを更新
make composer CMD="dump-autoload"
```

### PHPファイルの配置

- PHPファイルは `src/` ディレクトリに配置してください
- `src/index.php` が既に作成されており、動作確認とMySQL接続テストが可能です

### データベース接続情報

- **ホスト**: `mysql` (コンテナ内から) / `localhost` (ホストから)
- **ポート**: 3306
- **データベース名**: `testdb`
- **ユーザー名**: `testuser`
- **パスワード**: `testpassword`
- **Rootパスワード**: `rootpassword`

### phpMyAdmin

http://localhost:8080 でアクセスできます。
- **サーバー**: mysql
- **ユーザー名**: testuser
- **パスワード**: testpassword

### デバッグ設定（Xdebug）

IDEでXdebugを使用するための設定：

1. **ポート**: 9003
2. **IDE Key**: PHPSTORM
3. **パスマッピング**: `/var/www/html` → `./src`
4. **ホスト**: host.docker.internal

#### VS Code設定例

`.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html": "${workspaceFolder}/src"
            }
        }
    ]
}
```

#### PhpStorm設定

1. Settings → PHP → Debug → Xdebug → Port: 9003
2. Settings → PHP → Servers → Name: localhost, Host: localhost, Port: 80
3. Path mappings: `/var/www/html` → `プロジェクトルート/src`

## 機能

### 大容量ファイルアップロード対応

- **最大アップロードサイズ**: 20GB
- **POST最大サイズ**: 20GB
- **実行時間制限**: 3600秒（1時間）
- **メモリ制限**: 512MB

### カスタムPHP拡張機能

以下の拡張機能がインストール済み：
- **Composer 2.8.10** (パッケージ管理)
- **GD** (画像処理)
- **PDO** (データベース接続)
- **PDO MySQL**
- **MySQLi**
- **Xdebug** (デバッグ)

## ディレクトリ構造

```
docker-example/
├── docker/                        # Docker設定ファイル
│   ├── nginx/
│   │   └── nginx.conf            # Nginx設定
│   ├── php/
│   │   ├── Dockerfile           # PHPカスタムイメージ
│   │   └── php.ini             # PHP設定
│   ├── phpmyadmin/
│   │   └── config.inc.php      # phpMyAdmin設定
│   └── mysql/                   # MySQL設定（将来の拡張用）
├── src/                          # PHPアプリケーションファイル
│   └── index.php               # サンプルファイル
├── db-data/                     # MySQLデータ永続化
├── docker-compose.yml          # Docker Compose設定
├── Makefile                   # 便利コマンド集
├── README.md                 # このファイル
└── CLAUDE.md                # Claude Code用プロジェクト説明
```

## トラブルシューティング

### ポートが使用中の場合

他のサービスがポートを使用している場合は、`docker-compose.yml` でポート番号を変更してください：

```yaml
ports:
  - "8000:80"  # 80番ポートを8000番に変更
```

### データベースに接続できない場合

1. MySQLコンテナが起動しているか確認：
   ```bash
   docker-compose ps
   ```

2. MySQLログを確認：
   ```bash
   docker-compose logs mysql
   ```

### Xdebugが動作しない場合

1. PHP設定を確認：
   ```bash
   make shell
   php -m | grep xdebug
   ```
   
   または
   
   ```bash
   docker-compose exec php php -m | grep xdebug
   ```

2. IDE側でポート9003がリッスンされているか確認
3. ファイアウォール設定を確認

### Composerでエラーが発生する場合

1. Composerバージョンを確認：
   ```bash
   make composer
   ```

2. PHPコンテナ内でComposerを直接実行：
   ```bash
   make shell
   composer --version
   ```

## データの永続化

- データベースのデータは `db-data/` ディレクトリに永続化されます
- 環境を削除してもデータは保持されます
- データを完全にリセットしたい場合：
  ```bash
  docker-compose down -v
  sudo rm -rf db-data/
  ```

## ライセンス

このプロジェクトはMITライセンスの下で提供されています。