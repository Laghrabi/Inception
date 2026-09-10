# Developer Documentation

How to set up, build, and manage the Inception project.

## Prerequisites

- Linux (VM), Docker, Docker Compose, `make`

## Setup

1. Add your domain to `/etc/hosts`:
   ```bash
   echo "127.0.0.1 <login>.42.fr" | sudo tee -a /etc/hosts
   ```
2. Create a `.env` file at the project root with non-sensitive config
   (domain, DB name, usernames).

Neither `.env` nor `secrets/` are committed to Git.

## Build & run

```bash
make          # build images and start all containers
make down     # stop containers (data kept)
make clean    # remove containers/images/networks
make fclean   # clean + remove volumes (⚠ deletes data)
make re       # fclean + make (full rebuild)
```

Equivalent raw command:
```bash
docker compose -f srcs/docker-compose.yml up --build -d
```

## Useful commands

```bash
docker ps                          # list containers
docker logs -f <container>         # follow logs
docker exec -it <container> bash   # shell into a container
docker volume ls                   # list volumes
docker network ls                  # list networks
```

## Project structure

```
srcs/
├── docker-compose.yml
└── requirements/
    ├── nginx/
    ├── wordpress/
    ├── mariadb/
    └── bonus/
        ├── static/
        ├── adminer/
        └── portainer/
```

## Data persistence

Three named volumes, mapped to host directories, keep data across restarts
and rebuilds (unless `make fclean` / `down -v` is used):

| Volume            | Stores                          |
|--------------------|-----------------------------------|
| `wordpress_data`     | WordPress files & uploads       |
| `mariadb_data`         | Database files                |
| `portainer_data`         | Portainer's own settings    |

Static and Adminer are stateless — no dedicated volume needed.