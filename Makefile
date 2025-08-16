# Docker開発環境用Makefile

.PHONY: help up down build rebuild restart status logs shell composer mysql phpmyadmin mailhog mailpit redis clean adminer redis-commander cs-fix cs-check phpstan test health info ngrok ngrok-logs profiles-list profiles-help minio

# デフォルトコマンド - ヘルプを表示
help:
	@echo "使用可能なコマンド:"
	@echo ""
	@echo "  === 基本操作 ==="
	@echo "  make up        - すべてのサービスを起動"
	@echo "  make down      - すべてのサービスを停止"
	@echo "  make build     - イメージをビルドして起動"
	@echo "  make rebuild   - キャッシュなしでイメージを再ビルド"
	@echo "  make restart   - サービスを再起動"
	@echo "  make status    - サービスの状態を確認"
	@echo "  make health    - サービスの健康状態を確認"
	@echo "  make logs      - ログを表示 (サービス名指定可能: make logs SERVICE=php)"
	@echo "  make shell     - PHPコンテナにシェルでログイン"
	@echo "  make clean     - 停止してボリュームとイメージを削除"
	@echo ""
	@echo "  === 開発ツール ==="
	@echo "  make composer  - Composerコマンドを実行 (例: make composer CMD=install)"
	@echo "  make cs-fix    - PHP-CS-Fixerでコードを自動修正"
	@echo "  make cs-check  - PHP-CS-Fixerでコードスタイルをチェック"
	@echo "  make phpstan   - PHPStanで静的解析を実行"
	@echo "  make test      - テストを実行"
	@echo ""
	@echo "  === データベース・管理 ==="
	@echo "  make mysql     - MySQLクライアントに接続"
	@echo "  make phpmyadmin - phpMyAdminのURLを表示"
	@echo "  make adminer   - AdminerのURLを表示"
	@echo "  make redis     - Redisクライアントに接続"
	@echo "  make redis-commander - Redis CommanderのURLを表示"
	@echo "  make mailhog   - MailHogのURLを表示"
	@echo "  make mailpit   - MailpitのURLを表示"
	@echo "  make minio     - MinIOのURLを表示"
	@echo "  make ngrok     - NgrokのURLを表示（外部公開用）"
	@echo "  make ngrok-logs - Ngrokのログを表示"
	@echo ""
	@echo "  === 環境情報・設定 ==="
	@echo "  make info            - 開発環境の詳細情報を表示"
	@echo "  make profiles-list   - 利用可能なプロファイル一覧を表示"
	@echo "  make profiles-help   - プロファイル設定方法のヘルプを表示"

# サービス起動
up:
	docker-compose up -d

# サービス停止
down:
	docker-compose down

# ビルドして起動
build:
	docker-compose up --build -d

# キャッシュなしで再ビルド
rebuild:
	docker-compose build --no-cache
	docker-compose up -d

# サービス再起動
restart:
	docker-compose restart

# サービス状態確認
status:
	docker-compose ps

# サービス健康状態確認
health:
	@echo "=== Docker Health Check Status ==="
	docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

# ログ表示（オプション: SERVICE=サービス名）
logs:
ifdef SERVICE
	docker-compose logs -f $(SERVICE)
else
	docker-compose logs -f
endif

# PHPコンテナにシェルでログイン
shell:
	docker-compose exec php bash

# Composerコマンド実行（例: make composer CMD=install）
composer:
ifndef CMD
	@echo "使用例: make composer CMD=install"
	@echo "        make composer CMD=\"require symfony/console\""
	docker-compose exec php composer
else
	docker-compose exec php composer $(CMD)
endif

# MySQLクライアント接続
mysql:
	docker-compose exec mysql mysql -u user -ppassword testdb

# phpMyAdminのURL表示
phpmyadmin:
	@echo "phpMyAdminはこちら: http://localhost:$${PHPMYADMIN_PORT:-8080}"
	@echo "サーバー: mysql"
	@echo "ユーザー: user"
	@echo "パスワード: password"

# MailHogのURL表示
mailhog:
	@echo "MailHog WebUIはこちら: http://localhost:$${MAILHOG_WEB_PORT:-8025}"
	@echo "SMTP設定:
	@echo "  ホスト: mailhog (Docker内) / localhost (ホストから)"
	@echo "  ポート: $${MAILHOG_SMTP_PORT:-1025}"
	@echo "  認証: なし"

# Redisクライアント接続
redis:
	docker-compose exec redis redis-cli

# 環境をクリーンアップ
clean:
	docker-compose down -v
	docker-compose down --rmi all
	@echo "永続化データも削除する場合は手動で rm -rf data/ を実行してください"
	@echo "データディレクトリ構造: data/mysql, data/redis, data/minio"

# Adminer URL表示
adminer:
	@echo "Adminerはこちら: http://localhost:$${ADMINER_PORT:-8081}"
	@echo "サーバー: mysql"
	@echo "ユーザー: user"
	@echo "パスワード: password"
	@echo "データベース: testdb"

# Redis Commander URL表示
redis-commander:
	@echo "Redis Commanderはこちら: http://localhost:$${REDIS_COMMANDER_PORT:-8082}"

# Mailpit URL表示
mailpit:
	@echo "Mailpitはこちら: http://localhost:$${MAILPIT_WEB_PORT:-8026}"
	@echo "SMTP設定:"
	@echo "  ホスト: mailpit (Docker内) / localhost (ホストから)"
	@echo "  ポート: $${MAILPIT_SMTP_PORT:-1026}"
	@echo "  認証: なし"

# MinIO URL表示
minio:
	@echo "MinIO Consoleはこちら: http://localhost:$${MINIO_CONSOLE_PORT:-9001}"
	@echo "MinIO API: http://localhost:$${MINIO_API_PORT:-9000}"
	@echo "認証情報:"
	@echo "  ユーザー: $${MINIO_ROOT_USER:-minioadmin}"
	@echo "  パスワード: $${MINIO_ROOT_PASSWORD:-minioadmin}"
	@echo ""
	@echo "S3互換エンドポイント:"
	@echo "  Endpoint: http://localhost:$${MINIO_API_PORT:-9000}"
	@echo "  Access Key: $${MINIO_ROOT_USER:-minioadmin}"
	@echo "  Secret Key: $${MINIO_ROOT_PASSWORD:-minioadmin}"

# PHP-CS-Fixerでコード自動修正
cs-fix:
	docker-compose exec php php-cs-fixer fix ./

# PHP-CS-Fixerでコードスタイルチェック
cs-check:
	docker-compose exec php php-cs-fixer fix ./ --dry-run --diff

# PHPStan静的解析
phpstan:
	docker-compose exec php phpstan analyse ./

# テスト実行
test:
	@echo "テストフレームワークが設定されていません"
	@echo "PHPUnitやPestなどを設定してからこのコマンドを更新してください"

# 開発環境の詳細情報表示
info:
	@echo "=== Docker開発環境情報 ==="
	@echo "ウェブサイト: http://localhost:$${NGINX_PORT:-80} (FrankenPHP)"
	@echo ""
	@echo "データベース管理:"
	@echo "  phpMyAdmin: http://localhost:$${PHPMYADMIN_PORT:-8080}"
	@echo "  Adminer: http://localhost:$${ADMINER_PORT:-8081}"
	@echo ""
	@echo "Redis管理:"
	@echo "  Redis Commander: http://localhost:$${REDIS_COMMANDER_PORT:-8082}"
	@echo ""
	@echo "メール送信テスト:"
	@echo "  MailHog WebUI: http://localhost:$${MAILHOG_WEB_PORT:-8025}"
	@echo "  Mailpit WebUI: http://localhost:$${MAILPIT_WEB_PORT:-8026}"
	@echo ""
	@echo "オブジェクトストレージ:"
	@echo "  MinIO Console: http://localhost:$${MINIO_CONSOLE_PORT:-9001}"
	@echo "  MinIO API: http://localhost:$${MINIO_API_PORT:-9000}"
	@echo ""
	@echo "接続情報:"
	@echo "  MySQL: localhost:$${MYSQL_PORT:-3306} (testdb/user/password)"
	@echo "  Redis: localhost:$${REDIS_PORT:-6379}"
	@echo "  SMTP: localhost:$${MAILHOG_SMTP_PORT:-1025} (MailHog), localhost:$${MAILPIT_SMTP_PORT:-1026} (Mailpit)"
	@echo "  Xdebug: ポート9003"
	@echo ""
	@echo "開発ツール:"
	@echo "  PHP-CS-Fixer: make cs-fix, make cs-check"
	@echo "  PHPStan: make phpstan"
	@echo ""
	@echo "外部公開:"
	@echo "  Ngrok WebUI: http://localhost:$${NGROK_WEB_PORT:-4040}"
	@echo "  外部URL: make ngrok で確認"
	@echo ""
	@echo "=== プロファイル設定 ==="
	@echo "現在のプロファイル: $${COMPOSE_PROFILES:-デフォルト}"
	@echo "設定変更: .envファイルのCOMPOSE_PROFILESを編集"
	@echo "ヘルプ: make profiles-help"
	@echo "==========================

# Ngrok URL表示
ngrok:
	@echo "=== Ngrok 設定方法 ==="
	@echo "1. https://ngrok.com/でアカウント作成"
	@echo "2. 認証トークンを取得"
	@echo "3. .env ファイルに NGROK_AUTHTOKEN=your_token_here を追加"
	@echo ""
	@echo "=== Ngrok トンネル情報 ==="
	@echo "Ngrok WebUI: http://localhost:4040"
	@echo ""
	@echo "外部公開URL (API経由取得):"
	@curl -s http://localhost:$${NGROK_WEB_PORT:-4040}/api/tunnels | grep -o '"public_url":"[^"]*"' | sed 's/"public_url":"//g' | sed 's/"//g' | head -1 || echo "Ngrokが起動していないか、トンネルが確立されていません"
	@echo ""
	@echo "注意: 外部に公開されるため、開発・テスト用途のみで使用してください"

# Ngrok ログ表示
ngrok-logs:
	docker-compose logs -f ngrok

# 利用可能なプロファイル一覧表示
profiles-list:
	@echo "=== 利用可能なサービスプロファイル ==="
	@echo "php             - FrankenPHP (Webサーバー + PHP)"
	@echo "mysql           - MySQLデータベース"
	@echo "phpmyadmin      - phpMyAdmin (データベース管理)"
	@echo "mailhog         - MailHog (メール送信テスト)"
	@echo "redis           - Redisサーバー"
	@echo "adminer         - Adminer (データベース管理)"
	@echo "redis-commander - Redis Commander (Redis管理)"
	@echo "mailpit         - Mailpit (メール送信テスト - MailHogの代替)"
	@echo "minio           - MinIO (S3互換オブジェクトストレージ)"
	@echo "ngrok           - Ngrok (外部公開)"
	@echo ""
	@echo "現在の設定: $${COMPOSE_PROFILES:-デフォルト}"

# プロファイル設定方法のヘルプ表示
profiles-help:
	@echo "=== プロファイル設定方法 ==="
	@echo ""
	@echo "1. .envファイルでCOMPOSE_PROFILESを設定："
	@echo "   COMPOSE_PROFILES=php,mysql,phpmyadmin"
	@echo ""
	@echo "2. 設定例："
	@echo "   # 基本的なPHP開発環境"
	@echo "   COMPOSE_PROFILES=php,mysql,phpmyadmin"
	@echo ""
	@echo "   # メール送信テストを含む"
	@echo "   COMPOSE_PROFILES=php,mysql,phpmyadmin,mailhog"
	@echo ""
	@echo "   # Redis使用のアプリケーション"
	@echo "   COMPOSE_PROFILES=php,mysql,redis,redis-commander"
	@echo ""
	@echo "   # 外部公開が必要な場合"
	@echo "   COMPOSE_PROFILES=php,mysql,ngrok"
	@echo ""
	@echo "   # ファイルストレージを含む"
	@echo "   COMPOSE_PROFILES=php,mysql,minio"
	@echo ""
	@echo "   # 全サービス"
	@echo "   COMPOSE_PROFILES=php,mysql,phpmyadmin,mailhog,redis,adminer,redis-commander,mailpit,minio,ngrok"
	@echo ""
	@echo "3. 設定後、make down && make up で変更を適用"
	@echo ""
	@echo "4. ポート設定も.envファイルで変更可能："
	@echo "   NGINX_PORT=8080"
	@echo "   MYSQL_PORT=3307"
	@echo "   など"

