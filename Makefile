# Docker開発環境用Makefile

.PHONY: help up down build rebuild restart status logs shell composer mysql phpmyadmin mailhog mailpit redis clean adminer redis-commander cs-fix cs-check phpstan test health info ngrok ngrok-logs

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
	@echo "  make logs      - ログを表示 (サービス名指定可能: make logs SERVICE=nginx)"
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
	@echo "  make ngrok     - NgrokのURLを表示（外部公開用）"
	@echo "  make ngrok-logs - Ngrokのログを表示"
	@echo ""
	@echo "  === 環境情報 ==="
	@echo "  make info      - 開発環境の詳細情報を表示"

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
	docker-compose exec mysql mysql -u testuser -ptestpassword testdb

# phpMyAdminのURL表示
phpmyadmin:
	@echo "phpMyAdminはこちら: http://localhost:8080"
	@echo "サーバー: mysql"
	@echo "ユーザー: testuser"
	@echo "パスワード: testpassword"

# MailHogのURL表示
mailhog:
	@echo "MailHog WebUIはこちら: http://localhost:8025"
	@echo "SMTP設定:"
	@echo "  ホスト: mailhog (Docker内) / localhost (ホストから)"
	@echo "  ポート: 1025"
	@echo "  認証: なし"

# Redisクライアント接続
redis:
	docker-compose exec redis redis-cli

# 環境をクリーンアップ
clean:
	docker-compose down -v
	docker-compose down --rmi all
	@echo "DBデータも削除する場合は手動で rm -rf db-data/ を実行してください"

# Adminer URL表示
adminer:
	@echo "Adminerはこちら: http://localhost:8081"
	@echo "サーバー: mysql"
	@echo "ユーザー: testuser"
	@echo "パスワード: testpassword"
	@echo "データベース: testdb"

# Redis Commander URL表示
redis-commander:
	@echo "Redis Commanderはこちら: http://localhost:8082"

# Mailpit URL表示
mailpit:
	@echo "Mailpitはこちら: http://localhost:8026"
	@echo "SMTP設定:"
	@echo "  ホスト: mailpit (Docker内) / localhost (ホストから)"
	@echo "  ポート: 1026"
	@echo "  認証: なし"

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
	@echo "ウェブサイト: http://localhost"
	@echo ""
	@echo "データベース管理:"
	@echo "  phpMyAdmin: http://localhost:8080"
	@echo "  Adminer: http://localhost:8081"
	@echo ""
	@echo "Redis管理:"
	@echo "  Redis Commander: http://localhost:8082"
	@echo ""
	@echo "メール送信テスト:"
	@echo "  MailHog WebUI: http://localhost:8025"
	@echo "  Mailpit WebUI: http://localhost:8026"
	@echo ""
	@echo "接続情報:"
	@echo "  MySQL: localhost:3306 (testdb/testuser/testpassword)"
	@echo "  Redis: localhost:6379"
	@echo "  SMTP: localhost:1025 (MailHog), localhost:1026 (Mailpit)"
	@echo "  Xdebug: ポート9003"
	@echo ""
	@echo "開発ツール:"
	@echo "  PHP-CS-Fixer: make cs-fix, make cs-check"
	@echo "  PHPStan: make phpstan"
	@echo ""
	@echo "外部公開:"
	@echo "  Ngrok WebUI: http://localhost:4040"
	@echo "  外部URL: make ngrok で確認"
	@echo "=========================="

# Ngrok URL表示
ngrok:
	@echo "=== Ngrok トンネル情報 ==="
	@echo "Ngrok WebUI: http://localhost:4040"
	@echo ""
	@echo "外部公開URL (API経由取得):"
	@curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"' | sed 's/"public_url":"//g' | sed 's/"//g' | head -1 || echo "Ngrokが起動していないか、トンネルが確立されていません"
	@echo ""
	@echo "注意: 外部に公開されるため、開発・テスト用途のみで使用してください"

# Ngrok ログ表示
ngrok-logs:
	docker-compose logs -f ngrok


