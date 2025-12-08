DOCKER_COMPOSE := docker compose
PROJECT_NAME := inception
WP_IMAGE := $(PROJECT_NAME)-wordpress
DB_IMAGE := $(PROJECT_NAME)-mariadb
DOMAIN_NAME := andefern.42.fr

HOME_DATA_DIR := $(HOME)/data
CERTS_DIR := ./certs

export DOCKER_COMPOSE HOME_DATA_DIR CERTS_DIR USER DOMAIN_NAME

all: up

certs:
	@mkdir -p $(CERTS_DIR)
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(CERTS_DIR)/$(DOMAIN_NAME).key -out $(CERTS_DIR)/$(DOMAIN_NAME).crt -subj "/C=ES/ST=Bizkaia/L=Urduliz/O=42 Urduliz/OU=IT/CN=$(DOMAIN_NAME)"
	@sudo chown -R $(USER):$(USER) $(CERTS_DIR)
	@sudo chmod -R 644 $(CERTS_DIR)

up: certs
	@sudo mkdir -p $(HOME_DATA_DIR)/mariadb $(HOME_DATA_DIR)/wordpress
	@sudo chown -R $(USER):$(USER) $(HOME_DATA_DIR)
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build

down:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down

clean: down
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down -v --remove-orphans || true
	@docker system prune -af --volumes || true
	@sudo rm -rf $(HOME_DATA_DIR)/mariadb/* $(HOME_DATA_DIR)/wordpress/*
	@sudo rm -rf $(CERTS_DIR)

fclean: clean
	@sudo rm -rf $(HOME_DATA_DIR)
	@echo "Limpieza profunda completada (Contenedores, volúmenes y carpetas del host eliminadas)."

re: fclean up

.PHONY: all build up down clean fclean re certs