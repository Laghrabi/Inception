DIR = srcs/docker-compose.yml

all: up

up:
		@mkdir -p /home/claghrab/data/mariadb
		@mkdir -p /home/claghrab/data/wordpress
		@mkdir -p /home/claghrab/data/portainer
		@docker compose -f $(DIR) up --build -d

down:
		@docker compose -f $(DIR) down

clean: down
		@docker system prune -af

fclean: clean
		@docker system prune -af --volumes
		@sudo rm -rf /home/claghrab/data/wordpress/*
		@sudo rm -rf /home/claghrab/data/mariadb/*
		@sudo rm -rf /home/claghrab/data/portainer/*

re: fclean all

.PHONY: all up down clean fclean re
