# User Documentation

This document explains how to use and manage the Inception infrastructure as an end user or administrator.

---

## What services are provided

The stack runs three services:

| Service | Role | Access |
|---|---|---|
| NGINX | Web server and TLS termination | `https://bekinci-.42.fr` |
| WordPress | Website and admin panel | `https://bekinci-.42.fr/wp-admin` |
| MariaDB | Database (internal only) | Not accessible from outside |

NGINX is the only service exposed to the outside world, on port 443 (HTTPS). MariaDB and WordPress are only reachable from within the Docker network.

---

## Starting and stopping the project

**Start:**
```bash
make
```

**Stop (keeps data):**
```bash
make down
```

**Full reset (deletes all data and volumes):**
```bash
make fclean
make
```

---

## Accessing the website

Once the stack is running, open your browser and go to:

```
https://bekinci-.42.fr
```

Your browser will warn about a self-signed certificate — this is expected. Accept the warning to continue.

### Accessing the admin panel

Go to:
```
https://bekinci-.42.fr/wp-admin
```

Log in with the administrator account:

| Field | Value |
|---|---|
| Username | `bekinci` |
| Password | contents of `secrets/credentials.txt` |

---

## Credentials

All sensitive credentials are stored in the `secrets/` directory at the root of the repository. This directory must never be committed to Git.

| File | Contains |
|---|---|
| `secrets/credentials.txt` | WordPress administrator password |
| `secrets/db_password.txt` | MariaDB user password |
| `secrets/db_root_password.txt` | MariaDB root password |

Non-sensitive configuration (usernames, domain name, email addresses) is stored in `srcs/.env`.

---

## Checking that services are running

**See running containers:**
```bash
docker ps
```

You should see three containers: `nginx`, `wordpress`, `mariadb` — all with status `Up`.

**Check logs for a specific service:**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Check that the website responds:**
```bash
curl -k https://bekinci-.42.fr
```

The `-k` flag ignores the self-signed certificate warning.

**Check MariaDB is accepting connections:**
```bash
docker exec -it mariadb mariadb-admin ping -u bekinci- -p
```

Enter the password from `secrets/db_password.txt` when prompted.
