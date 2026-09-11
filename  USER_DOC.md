# User Documentation

How to use the Inception stack as an end user or administrator.

## Services

| Service    | What it is                            |
|------------|----------------------------------------|
| NGINX      | Entry point, serves everything over HTTPS |
| WordPress  | The website (CMS)                      |
| MariaDB    | The database used by WordPress         |
| Static     | A simple standalone static page (bonus)|
| Adminer    | Web UI to manage the database (bonus)  |
| Portainer  | Web UI to manage Docker itself (bonus) |

## Start / stop

```bash
make        # build and start everything
make down   # stop everything (data is kept)
make re     # rebuild and restart
```

## Access

| What            | URL                                 |
|------------------|---------------------------------------|
| Website           | `https://<login>.42.fr`             |
| WordPress admin    | `https://<login>.42.fr/wp-admin`   |
| Static page          | `https://<login>.42.fr/portfolio`  |
| Adminer                | `https://<login>.42.fr/adminer` |
| Portainer                 | `https://<login>.42.fr/portainer` |

Your browser will warn about the certificate (it's self-signed) — proceed anyway.

## Credentials

- Usernames / domain / DB name / passwords → `.env` file

Both are at the project root and are not committed to Git.

## Check everything is running

```bash
docker ps                   # all containers should be "Up"
docker logs <container>     # check a specific service's logs
```

If something looks wrong, check the logs of that container first.