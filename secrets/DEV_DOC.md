# Developer Documentation

This document describes how to set up, build, and manage the Inception project from a developer perspective.

---

## Prerequisites

The following must be installed inside your Virtual Machine before starting:

- Docker (>= 20.10)
- Docker Compose (>= 2.0, as a plugin — `docker compose` not `docker-compose`)
- `make`
- `sudo` access

---

## Project structure

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt       ← WordPress admin password
│   ├── db_password.txt       ← MariaDB user password
│   └── db_root_password.txt  ← MariaDB root password
└── srcs/
    ├── .env                  ← Non-sensitive environment variables
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb.conf
        │   └── tools/
        │       └── create_db.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── nginx.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── www.conf
        │   └── tools/
        │       └── create_wp.sh
        └── tools/
            └── mkdir.sh
```

---

## Setting up from scratch

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd inception
```

### 2. Configure the domain

Add the following line to `/etc/hosts` inside the VM:

```
127.0.0.1   bekinci-.42.fr
```

### 3. Verify secrets

The `secrets/` directory must contain three files with the actual passwords:

```bash
cat secrets/credentials.txt    # WordPress admin password
cat secrets/db_password.txt    # MariaDB user password
cat secrets/db_root_password.txt  # MariaDB root password
```

These files must exist before running `make`. They are never committed to Git (add `secrets/` to `.gitignore`).

### 4. Verify environment variables

Check `srcs/.env`:

```env
DOMAIN_NAME=bekinci-.42.fr

DB_DATABASE=wordpress_db
DB_USER=bekinci-

WP_ROOT_USER=bekinci
WP_ROOT_EMAIL=bekinci@inception

WP_USER=user
WP_USER_EMAIL=user@inception
WP_USER_PASSWORD=User1234
```

---

## Building and launching

```bash
make
```

This command does three things in order:
1. Runs `mkdir.sh` to create `/home/bekinci-/data/mariadb` and `/home/bekinci-/data/wordpress` on the host
2. Runs `docker compose up --build -d` to build all images and start all containers
3. Prints a confirmation message

---

## Managing containers and volumes

**View running containers:**
```bash
docker ps
```

**View all containers including stopped ones:**
```bash
docker ps -a
```

**View logs:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

**Enter a running container:**
```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash
```

**Connect to MariaDB from inside the container:**
```bash
docker exec -it mariadb mariadb -u root -p
# password: contents of secrets/db_root_password.txt
```

**View Docker volumes:**
```bash
docker volume ls
```

**Stop containers without removing data:**
```bash
make down
```

**Remove containers, images, and cache (keeps volume data):**
```bash
make clean
```

**Full reset — removes everything including persistent data:**
```bash
make fclean
```

**Rebuild from scratch:**
```bash
make re
```

---

## Where data is stored and how it persists

Docker named volumes are used for persistent storage. Both volumes are backed by directories on the host machine:

| Volume | Container path | Host path |
|---|---|---|
| `db_data` | `/var/lib/mysql` | `/home/bekinci-/data/mariadb` |
| `wp_data` | `/var/www/wordpress` | `/home/bekinci-/data/wordpress` |

Both NGINX and WordPress mount `wp_data` — NGINX reads the static files directly while WordPress writes them via php-fpm.

Because data lives on the host, it survives container restarts and even `make clean`. Only `make fclean` deletes it by running `sudo rm -rf /home/bekinci-/data`.

---

## How each service initializes

**MariaDB** (`create_db.sh`):
1. Reads passwords from `/run/secrets/`
2. Initializes the data directory if it does not exist (`mysql_install_db`)
3. Starts a temporary `mysqld_safe` process
4. Creates the database, sets the root password, creates the user with privileges
5. Shuts down the temporary process
6. Starts the final `mysqld_safe` as PID 1

**WordPress** (`create_wp.sh`):
1. Reads passwords from `/run/secrets/`
2. Waits until MariaDB is ready to accept connections
3. If `wp-config.php` does not exist, runs `wp config create` and `wp core install`
4. Creates a second WordPress user with the author role
5. Starts `php-fpm8.2` as PID 1

**NGINX** (`nginx.sh`):
1. Generates a self-signed TLS certificate if one does not exist
2. Starts `nginx` in the foreground (`daemon off`) as PID 1

---

## Security notes

- Passwords are never written in Dockerfiles or `docker-compose.yml`
- Secrets are passed via Docker secrets and read from `/run/secrets/` at runtime
- The `secrets/` directory must be listed in `.gitignore`
- The `latest` tag is not used for any base image
- `network: host` and `--link` are not used
- No container uses infinite loop entrypoints (`tail -f`, `sleep infinity`, etc.)
