# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DOMAIN_NAME = andefern.42.fr
DATA_PATH = /home/andefern/data
MYSQL_DATA = $(DATA_PATH)/mysql
WP_DATA = $(DATA_PATH)/wordpress
CERTS_DIR = ./certs

# Colores
GREEN = \033[0;32m
BLUE = \033[0;34m
YELLOW = \033[0;33m
RED = \033[0;31m
RESET = \033[0m

# Objetivos
.PHONY: all build up down clean fclean re logs status help setup certs

all: build up

certs:
	@echo "$(BLUE)Generando certificado SSL para $(DOMAIN_NAME)...$(RESET)"
	@mkdir -p $(CERTS_DIR)
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(CERTS_DIR)/$(DOMAIN_NAME).key -out $(CERTS_DIR)/$(DOMAIN_NAME).crt -subj '/C=ES/ST=Bizkaia/L=Urduliz/O=42 Urduliz/OU=IT/CN=$(DOMAIN_NAME)'
	@sudo chown -R $(USER):$(USER) $(CERTS_DIR)
	@sudo chmod -R 644 $(CERTS_DIR)
	@echo "$(GREEN)✓ Certificado generado y permisos ajustados$(RESET)"

setup:
	@echo "$(BLUE)Creando y configurando directorios de datos...$(RESET)"
	@sudo mkdir -p $(MYSQL_DATA)
	@sudo mkdir -p $(WP_DATA)
	@sudo chown -R $(USER):$(USER) $(DATA_PATH)
	@echo "$(GREEN)✓ Directorios creados y permisos ajustados$(RESET)"
	@echo "$(BLUE)Configurando /etc/hosts...$(RESET)"
	@grep -q "$(DOMAIN_NAME)" /etc/hosts || echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null
	@echo "$(GREEN)✓ Host configurado$(RESET)"

build: setup
	@echo "$(BLUE)Construyendo imágenes Docker...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Imágenes construidas$(RESET)"

up: certs build
	@echo "$(BLUE)Iniciando contenedores...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Contenedores iniciados$(RESET)"

down:
	@echo "$(YELLOW)Deteniendo contenedores...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Contenedores detenidos$(RESET)"

clean: down
	@echo "$(YELLOW)Limpiando contenedores y redes...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)✓ Limpieza completada$(RESET)"

fclean: clean
	@echo "$(RED)Eliminando imágenes, volúmenes, datos y certificados...$(RESET)"
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)
	@sudo rm -rf $(CERTS_DIR)
	@echo "$(GREEN)✓ Limpieza profunda completada$(RESET)"

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

status:
	@echo "$(BLUE)Estado de los contenedores:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) ps

help:
	@echo "$(BLUE)Comandos disponibles:$(RESET)"
	@echo "  $(GREEN)make all$(RESET)     - Construir e iniciar todo"
	@echo "  $(GREEN)make build$(RESET)   - Construir las imágenes"