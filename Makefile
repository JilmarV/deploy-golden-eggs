.PHONY: all clean clone frontend-build build up down logs restart
all: clone setup-frontend build up

clone:
	@if [ -d "./backend/.git" ]; then \
		echo "Actualizando backend..."; \
		cd backend && git pull origin main; \
	else \
		echo "Clonando backend..."; \
		git clone https://github.com/JilmarV/prueba-back.git ./backend; \
	fi
	@if [ -d "./frontend/.git" ]; then \
		echo "Actualizando frontend..."; \
		cd frontend && git pull origin main; \
	else \
		echo "Clonando frontend..."; \
		git clone https://github.com/JilmarV/prueba-front.git ./frontend; \
	fi

setup-frontend:
	@echo "Configurando frontend..."
	@if [ ! -f frontend/nginx.conf ]; then \
		echo "Advertencia: nginx.conf no está en frontend/"; \
	fi
	@cp frontend/Dockerfile frontend/ 2>/dev/null || echo "Dockerfile ya existe en frontend"

frontend-build:
	@echo "Construyendo frontend localmente..."
	cd frontend && npm install && npm run build

build:
	@echo "Construyendo contenedores Docker..."
	docker compose build --no-cache

up:
	@echo "Iniciando servicios..."
	docker compose up -d

down:
	@echo "Deteniendo servicios..."
	docker compose down

logs:
	docker compose logs -f

restart: down build up

clean:
	@echo "Limpiando contenedores e imágenes..."
	docker compose down -v
	docker system prune -f

run-test:
	@docker compose exec api bash -c "cd /app && pytest -v"

validate-pylint:
	@pylint backend/app/

logs-frontend:
	docker compose logs -f frontend

logs-api:
	docker compose logs -f api

shell-frontend:
	docker compose exec frontend sh

shell-api:
	docker compose exec api bash
