*This project has been created as part of the 42 curriculum by claghrab.*

# Inception

## Table of Contents
- [Description](#description)
- [Instructions](#instructions)
- [Project Architecture](#project-architecture)
- [Design Choices & Comparisons](#design-choices--comparisons)
  - [Virtual Machines vs Docker](#virtual-machines-vs-docker)
  - [Secrets vs Environment Variables](#secrets-vs-environment-variables)
  - [Docker Network vs Host Network](#docker-network-vs-host-network)
  - [Docker Volumes vs Bind Mounts](#docker-volumes-vs-bind-mounts)
- [Resources](#resources)

---

## Description

**Inception** is a system administration project from the 42 curriculum whose goal is
to learn the fundamentals of Docker by building a small, production-like infrastructure
entirely from containers that you write and configure yourself, instead of relying on
pre-built images from Docker Hub.

The project asks you to set up, using `docker-compose` and custom Dockerfiles based on
a stable Linux distribution (e.g. Debian or Alpine), a set of interconnected services
running each in its own container:

- **NGINX** — the single entry point to the infrastructure, serving traffic over TLS
  (TLSv1.2/TLSv1.3 only).
- **WordPress + php-fpm** — the actual website, running without NGINX bundled inside it
  (php-fpm only, no web server).
- **MariaDB** — the database used by WordPress, with no web server involved either.

All services must restart automatically in case of a crash, must not use `network: host`,
`--link`, or the `latest` tag for images, and must communicate through a dedicated Docker
network. Additional bonus services (Redis, FTP, static website, Adminer, a custom service,
etc.) can be added on top of the mandatory part.

The overall goal is to understand:
- how to containerize and orchestrate multiple services,
- how to write clean, minimal, and secure Dockerfiles,
- how to persist data properly,
- how to manage sensitive configuration safely,
- and how all of this compares to more traditional infrastructure approaches like
  virtual machines.

---

## Instructions

### Requirements
- A Linux virtual machine (the project is evaluated on a VM, not on a host machine).
- Docker and Docker Compose installed.
- A `.env` file at the root of the project (not committed to Git) containing the
  environment variables used by the containers (domain name, database name/user/password,
  WordPress admin credentials, etc.).
- Secrets (passwords, keys) stored under a `secrets/` folder and **not** committed to Git.

### Setup

1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd inception
   ```

2. Add a line to your `/etc/hosts` mapping your login-based domain to localhost, e.g.:
   ```
   127.0.0.1 <login1>.42.fr
   ```

3. Create the `.env` file at the project root (see `.env.example` if provided) and fill
   in the required variables (domain name, MySQL root/user credentials, WordPress admin
   user/password, etc.).

4. Create the secret files expected under `secrets/` (e.g. `db_password.txt`,
   `db_root_password.txt`, `wp_admin_password.txt`).

5. Build and start the whole infrastructure:
   ```bash
   make
   ```
   or, without a Makefile wrapper:
   ```bash
   docker-compose -f srcs/docker-compose.yml up --build -d
   ```

6. Visit `https://<login1>.42.fr` in your browser (accept the self-signed certificate
   warning, since TLS is self-signed for local development).

### Useful commands

| Command              | Description                                   |
|----------------------|------------------------------------------------|
| `make`               | Builds and starts all containers               |
| `make down`          | Stops and removes all containers               |
| `make clean`         | Removes containers, images, and networks       |
| `make fclean`        | `clean` + removes volumes (all persisted data) |
| `make re`            | `fclean` + `make` (full rebuild)               |
| `docker ps`          | List running containers                        |
| `docker-compose logs`| Inspect service logs                            |

### Stopping the project
```bash
make down
```

---

## Project Architecture

The infrastructure is described entirely with `docker-compose.yml` at the root of the
`srcs/` folder. Each service has its own directory containing a `Dockerfile` and its
configuration files:

```
srcs/
├── docker-compose.yml
└── requirements/
    ├── nginx/
    │   ├── Dockerfile
    │   └── conf/
    ├── wordpress/
    │   ├── Dockerfile
    │   ├── conf/
    │   └── tools/
    |   
    └── mariadb/
        ├── Dockerfile
        ├── conf/
        └── tools/
```

Every image is built **from scratch** on top of a chosen base distribution (no
`nginx:latest`, `wordpress:latest`, or `mariadb:latest` images), which is what
differentiates this project from a simple Docker Compose demo: the goal is to
understand what each service actually needs to run, not just to assemble prebuilt
images.

Data persistence is handled with Docker **volumes**, mapped to specific directories on
the host, so that WordPress files and the MariaDB database survive container restarts
and rebuilds.

---

## Design Choices & Comparisons

### Virtual Machines vs Docker

| Aspect            | Virtual Machine                                   | Docker Container                                  |
|--------------------|----------------------------------------------------|-----------------------------------------------------|
| Virtualization level | Hardware-level (full OS + kernel per VM)         | OS-level (shares host kernel)                       |
| Resource usage      | Heavy (dedicated RAM/CPU/disk per VM)             | Lightweight (shares host resources, minimal overhead)|
| Boot time            | Minutes                                          | Seconds                                              |
| Isolation            | Very strong (separate kernel)                    | Process-level isolation (namespaces/cgroups)         |
| Portability           | Large images, less portable                     | Small images, highly portable across environments    |
| Use case in this project | N/A (used only as the host running Docker)  | Each service (NGINX, WordPress, MariaDB) runs in its own lightweight, disposable container |

We chose Docker for this project because it lets us isolate each service (web server,
application, database) without the overhead of running a full OS per service, while
still keeping strong enough isolation for security and reproducibility. The VM is only
used here as the host machine on which Docker itself runs, since the school's evaluation
environment requires one.

### Secrets vs Environment Variables

| Aspect        | Environment Variables (`.env`)                | Docker Secrets                                   |
|----------------|------------------------------------------------|----------------------------------------------------|
| Visibility      | Readable via `docker inspect`, process env, `/proc` | Mounted as files, not exposed in `docker inspect` or process listing |
| Storage          | Often stored in plain text in `.env`         | Stored as files, can be encrypted at rest (Swarm)  |
| Best for          | Non-sensitive configuration (domain name, ports, service names) | Sensitive data (passwords, private keys, API tokens) |
| Used in project    | Non-critical configuration values           | Database and WordPress admin passwords, mounted as files under `/run/secrets/` |

In this project, environment variables (via `.env`) are used for general, non-sensitive
configuration (domain name, database names, usernames), while actual passwords are kept
as **secrets** — plain files outside of Git, mounted read-only into the containers — so
that sensitive credentials never end up in image layers, `docker-compose.yml`, or
`docker inspect` output.

### Docker Network vs Host Network

| Aspect          | Host Network                                  | Docker (bridge/user-defined) Network              |
|------------------|------------------------------------------------|------------------------------------------------------|
| Isolation          | None — container shares host's network stack | Isolated — containers get their own virtual network |
| Port conflicts      | Possible, since ports are shared with host  | Avoided, ports are only exposed explicitly           |
| Service discovery    | Manual (via localhost / host IP)           | Automatic (DNS resolution by container name)          |
| Security               | Weaker (containers see host network directly) | Stronger (traffic contained to the defined network)  |
| Required by subject      | Forbidden (`network: host` is banned)      | Mandatory — all containers communicate via a dedicated user-defined bridge network |

The subject explicitly forbids `network: host` and `--link`. We instead define a custom
Docker network in `docker-compose.yml` so that NGINX, WordPress, and MariaDB can reach
each other by container/service name (Docker's built-in DNS), while staying isolated
from the host's own network and from other unrelated containers.

### Docker Volumes vs Bind Mounts

| Aspect         | Bind Mounts                                     | Docker Volumes                                    |
|-----------------|---------------------------------------------------|-------------------------------------------------------|
| Managed by        | The host filesystem directly (arbitrary path)  | Docker itself (stored under `/var/lib/docker/volumes`) |
| Portability          | Tied to a specific host path/structure       | Portable, decoupled from host directory layout        |
| Permissions            | Inherits host file permissions, can cause conflicts | Managed by Docker, generally safer                  |
| Backup / lifecycle       | Manual                                    | Easier to manage/back up with Docker CLI               |
| Used in project             | Not used for persistent app data       | Used to persist WordPress files and the MariaDB database, mapped to specific host directories for evaluation purposes |

We use **Docker volumes** to persist the WordPress website files and the MariaDB
database across container restarts, rebuilds, and `docker-compose down`. Volumes are
the recommended Docker-native way to handle persistent data since they are managed,
portable, and decoupled from the exact internal layout of the containers, unlike raw
bind mounts.

---

## Resources

### Classic references
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [php-fpm Documentation](https://www.php.net/manual/en/install.fpm.php)
- 42 Paris Inception subject PDF (provided by the school intranet)

### AI usage disclosure
- AI tools were utilized during the development of this project for     architectural review and debugging purposes, and the creation of documentation files.
