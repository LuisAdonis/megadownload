# Makefile para facilitar comandos de Docker

.PHONY: help build up down restart logs clean status

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construir todas las imágenes Docker
	docker-compose build --no-cache

up: ## Iniciar todos los servicios
	docker-compose up -d

down: ## Detener todos los servicios
	docker-compose down

restart: ## Reiniciar todos los servicios
	docker-compose restart

logs: ## Ver logs de todos los servicios
	docker-compose logs -f

logs-api: ## Ver logs solo de la API
	docker-compose logs -f api

logs-flutter: ## Ver logs solo de Flutter Web
	docker-compose logs -f flutter_web

logs-mongo: ## Ver logs solo de MongoDB
	docker-compose logs -f mongodb

status: ## Ver estado de los servicios
	docker-compose ps

clean: ## Limpiar contenedores, volúmenes e imágenes
	docker-compose down -v --rmi all --remove-orphans

shell-api: ## Abrir shell en el contenedor de la API
	docker-compose exec api sh

shell-flutter: ## Abrir shell en el contenedor de Flutter
	docker-compose exec flutter_web sh

shell-mongo: ## Abrir shell de MongoDB
	docker-compose exec mongodb mongosh -u root -p facturacion

rebuild: down build up ## Reconstruir y reiniciar todo

rebuild-api: ## Reconstruir solo la API
	docker-compose build --no-cache api
	docker-compose up -d api

rebuild-flutter: ## Reconstruir solo Flutter Web
	docker-compose build --no-cache flutter_web
	docker-compose up -d flutter_web

health: ## Verificar salud de los servicios
	@echo "=== MongoDB ==="
	@curl -s http://localhost:27017 > /dev/null && echo "✓ MongoDB running" || echo "✗ MongoDB not responding"
	@echo "\n=== API ==="
	@curl -s http://localhost:3000/health | grep -q "ok" && echo "✓ API healthy" || echo "✗ API not responding"
	@echo "\n=== Flutter Web ==="
	@curl -s http://localhost:80 > /dev/null && echo "✓ Flutter Web running" || echo "✗ Flutter Web not responding"

install: ## Instalación inicial completa
	@echo "🚀 Instalando MegaDownload..."
	@make build
	@make up
	@echo "⏳ Esperando que los servicios estén listos..."
	@sleep 15
	@make health
	@echo "\n✅ Instalación completa!"
	@echo "📱 Flutter Web: http://localhost:80"
	@echo "🔌 API: http://localhost:3000"
	@echo "💾 MongoDB: mongodb://localhost:27017"