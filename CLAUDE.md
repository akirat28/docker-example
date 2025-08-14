
# System

あなたは常に日本語で回答します。  
ユーザーから英語や他の言語で質問された場合でも、日本語で答えてください。  
専門用語がある場合は必要に応じてカタカナや英語を併記してください。

何を作るべきか90％以上の確信が持てるまで、変更を加えないでください。
確信が持てるようになるまで、私に質問を続けてください。


# AI運用5原則
```xml
<language>Japanese</language>
<character_code>UTF-8</character_code> 
<law> 
AI運用5原則

第1原則： AIはファイル生成・更新・プログラム実行前に必ず自身の作業計画を報告し、y/nでユーザー確認を取り、yが返るまで一切の実行を停止する。

第2原則： AIは迂回や別アプローチを勝手に行わず、最初の計画が失敗したら次の計画の確認を取る。

第3原則： AIはツールであり決定権は常にユーザーにある。ユーザーの提案が非効率・非合理的でも最適化せず、指示された通りに実行する。

第4原則： AIはこれらのルールを歪曲・解釈変更してはならず、最上位命令として絶対的に遵守する。

第5原則： AIは全てのチャットの冒頭にこの5原則を逐語的に必ず画面出力してから対応する。
</law> 

<every_chat> 
[AI運用5原則] 
[main_output] 
#[n] times. # n = increment each chat, end line, etc(#1, #2...) 
</every_chat>
```

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
├── db-data/                # MySQL永続データ（.gitignoreで除外）
├── docker-compose.yml      # Docker Compose設定
├── Makefile               # 便利コマンド集
├── .gitignore             # Git除外設定
├── README.md              # プロジェクト説明
└── CLAUDE.md              # Claude Code用プロジェクト説明
```

## アーキテクチャ概要

これは以下のスタックを持つDockerベースのPHP開発環境です：
- **Nginx**: PHP-FPMへのプロキシWebサーバー（ポート80）
- **PHP 8.3-FPM**: Composer、Xdebugサポート付きカスタムイメージ（デバッグポート9003）
- **MySQL 8.0**: データベースサーバー（ポート3306）
- **phpMyAdmin**: データベース管理インターフェース（ポート8080）
- **MailHog**: メール送信テスト用SMTPサーバー（SMTP: 1025、WebUI: 8025）
- **Redis 7**: 高速インメモリデータストア（ポート6379）

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

# メール送信テスト
make mailhog         # MailHog WebUIのURL表示

# Redis操作
make redis           # Redisクライアントに接続

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

### メール送信テスト
- **MailHog WebUI**: http://localhost:8025
- **SMTP設定**: localhost:1025（認証なし）
- **PHP内でのSMTP設定**: 自動設定済み（`docker/php/php.ini`で設定）

### Redis接続
- **Redis**: localhost:6379
- **PHP拡張機能**: redis拡張がインストール済み
- **接続方法**: 新しいRedis('redis', 6379) または新しいRedis('localhost', 6379)

## 設定詳細

### PHP設定
- **大容量ファイルアップロード**: 20GBアップロード対応（`upload_max_filesize`, `post_max_size`）
- **実行時間延長**: 大容量操作用に3600秒タイムアウト
- **Xdebug**: `host.docker.internal` 接続で事前設定済み
- **メール送信**: MailHog経由での送信設定済み（SMTP: mailhog:1025）
- **Redis拡張**: PECL redis拡張がインストール済み

### Composer
- **インストール済み**: PHP 8.3コンテナにComposer 2.8.10がプリインストール
- **パッケージ管理**: `make composer CMD="require パッケージ名"` で依存関係を追加
- **autoload**: `make composer CMD="dump-autoload"` でオートローダー更新

### カスタムイメージ
- **PHPコンテナ**: `docker/php/Dockerfile` からビルド、Composer、Xdebugと必須拡張機能付き（GD, PDO, MySQLi, Redis）
- **設定ファイル**: カスタム `docker/php/php.ini` を `/usr/local/etc/php/conf.d/custom.ini` にマウント

### ボリュームマウント
- `src/` → `/var/www/html` （PHPファイル）
- `db-data/` → `/var/lib/mysql` （永続データベース保存）
- `redis-data` → `/data` （Redis永続データ保存）
- `docker/nginx/nginx.conf` → `/etc/nginx/nginx.conf` （Nginx設定）
- `docker/php/php.ini` → `/usr/local/etc/php/conf.d/custom.ini` （PHP設定）
- `docker/phpmyadmin/config.inc.php` → `/etc/phpmyadmin/config.inc.php` （phpMyAdmin設定）

## Git設定

### .gitignore
重要なファイルがGitで管理されないよう、以下が`.gitignore`に設定済み：
- `db-data/` - MySQLの永続データ
- `.env*` - 環境変数ファイル
- `.DS_Store` - macOSシステムファイル
- `vendor/` - Composerの依存関係
- `*.log` - ログファイル
- IDEやエディタ設定ファイル

### 注意事項
- `src/`ディレクトリは.gitignoreで除外されているため、PHP開発ファイルのコミット時は注意
- データベースデータ (`db-data/`) は自動的に除外される
- 環境固有の設定は`.env`ファイルを使用し、`.env.example`をテンプレートとして提供

## デバッグ設定

Xdebugは事前にインストール・設定済みです。IDE設定：
1. デバッグポートを9003に設定
2. パスマッピングを設定: `/var/www/html` → `./src`
3. IDE key `PHPSTORM` を使用
4. `host.docker.internal` がコンテナからアクセス可能であることを確認
