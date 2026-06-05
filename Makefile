NAME		=	inception

COMPOSE_FILE = srcs/docker-compose.yml

RESET			= \033[0m
RED				= \033[31m
GREEN			= \033[0;32m
YELLOW			= \033[0;33m
BLUE			= \033[0;34m

all:
	@bash srcs/requirements/tools/mkdir.sh
	@docker compose -f $(COMPOSE_FILE) up --build -d
	@echo "$(GREEN)Inception started..✅$(RESET)"

down:
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(RED)🛑 Inception container stop.$(RESET)"

clean: down
	@docker system prune -a -f
	@echo "$(RED)🧹 Containers and caches are being cleaned.$(RESET)"

fclean: clean
	@docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	@sudo rm -rf /home/bekinci-/data
	@echo "$(RED)🧽 All persistent data and volumes are being deleted.$(RESET)"

re: fclean all

.PHONY: all down clean fclean re