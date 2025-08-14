# Docker開発環境用Makefile

.PHONY: help up down build rebuild restart status logs shell composer mysql phpmyadmin mailhog redis clean

# デフォルトコマンド - ヘルプを表示
help:
	@echo "使用可能なコマンド:"
	@echo "  make up        - すべてのサービスを起動"
	@echo "  make down      - すべてのサービスを停止"
	@echo "  make build     - イメージをビルドして起動"
	@echo "  make rebuild   - キャッシュなしでイメージを再ビルド"
	@echo "  make restart   - サービスを再起動"
	@echo "  make status    - サービスの状態を確認"
	@echo "  make logs      - ログを表示 (サービス名指定可能: make logs SERVICE=nginx)"
	@echo "  make shell     - PHPコンテナにシェルでログイン"
	@echo "  make composer  - Composerコマンドを実行 (例: make composer CMD=install)"
	@echo "  make mysql     - MySQLクライアントに接続"
	@echo "  make phpmyadmin - phpMyAdminのURLを表示"
	@echo "  make mailhog   - MailHogのURLを表示"
	@echo "  make redis     - Redisクライアントに接続"
	@echo "  make clean     - 停止してボリュームとイメージを削除"

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

# 開発環境の詳細情報表示
info:
	@echo "=== Docker開発環境情報 ==="
	@echo "ウェブサイト: http://localhost"
	@echo "phpMyAdmin: http://localhost:8080"
	@echo "MailHog WebUI: http://localhost:8025"
	@echo "MySQL接続: localhost:3306"
	@echo "  データベース: testdb"
	@echo "  ユーザー: testuser"
	@echo "  パスワード: testpassword"
	@echo "Redis接続: localhost:6379"
	@echo "SMTP設定 (MailHog): localhost:1025"
	@echo "Xdebugポート: 9003"
	@echo "=========================="