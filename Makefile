# Aldagaiak

COMPOSE_FILE = srcs/docker-compose.yml
DOMAIN_NAME = andefern.42.fr
DATA_PATH = /home/andefern/data
MYSQL_DATA = $(DATA_PATH)/mysql
WP_DATA = $(DATA_PATH)/wordpress
CERTS_DIR = ./certs

# Kolorintxis

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
RESET = \033[0m

# Helburuak

.PHONY: all build up down clean fclean re logs status help setup certs

all: build up

certs:
	@echo "$(CYAN)SSL ziurtagiria sortzen $(DOMAIN_NAME)...$(RESET)"
	@mkdir -p $(CERTS_DIR)
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $(CERTS_DIR)/$(DOMAIN_NAME).key -out $(CERTS_DIR)/$(DOMAIN_NAME).crt -subj '/C=ES/ST=Bizkaia/L=Urduliz/O=42 Urduliz/OU=IT/CN=$(DOMAIN_NAME)'
	@sudo chown -R $(USER):$(USER) $(CERTS_DIR)
	@sudo chmod -R 644 $(CERTS_DIR)
	@echo "$(GREEN)✓ Sortutako ziurtagiria eta baimen doituak$(RESET)"

setup:
	@echo "$(CYAN)Datu direktorioak sortzen eta konfiguratzen...$(RESET)"
	@sudo mkdir -p $(MYSQL_DATA)
	@sudo mkdir -p $(WP_DATA)
	@sudo chown -R $(USER):$(USER) $(DATA_PATH)
	@echo "$(GREEN)✓ Baimenak  atzitu dira eta direktorioak sortu dira$(RESET)"
	@echo "$(CYAN)/etc/hosts konfiguratzen...$(RESET)"
	@grep -q "$(DOMAIN_NAME)" /etc/hosts || echo "127.0.0.1 $(DOMAIN_NAME)" | sudo tee -a /etc/hosts > /dev/null
	@echo "$(GREEN)✓ Host konfigurazioa$(RESET)"

build: setup
	@echo "$(CYAN)Docker irudiak eraikitzen...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Irudiak sortu egin dira$(RESET)"

up: certs build
	@echo "$(CYAN)Kontainerrak abiarazten...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Kontainerrak abiarazi egin dira$(RESET)"

down:
	@echo "$(YELLOW)Kontainerrak geldiarazten...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Kontainerrak geldiarazi egin dira$(RESET)"

clean: down
	@echo "$(YELLOW)Kontainerrak eta sareak garbitzen...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)✓ Dena garbi$(RESET)"

fclean: clean
	@echo "$(WHITE)Bolumenak, datuak, ziurtagiriak eta irudiak ezabatzen...$(RESET)"
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_PATH)
	@sudo rm -rf $(CERTS_DIR)
	@echo "$(GREEN)✓ Garbiketa sakona egin da$(RESET)"

re: fclean all

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

status:
	@echo "$(CYAN)Kontainerren edo edukiontzien egoera:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) ps

help:
	@echo "$(CYAN)Komando erabilgarriak:$(RESET)"
	@echo "  $(GREEN)make all$(RESET)     - Eraiki eta abiarazi"
	@echo "  $(GREEN)make build$(RESET)   - Irudiak eraiki"