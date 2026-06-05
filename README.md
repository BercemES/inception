*This project has been created as part of the 42 curriculum by bekinci-.*

# Inception

## Description

Inception is a system administration project that involves building a small web system using Docker. The goal is to orchestrate multiple services — NGINX, WordPress, and MariaDB — in separate containers that communicate with each other.

The project helps you learn important basics like using containers, separating services, managing passwords safely, and keeping data saved permanently.

### Architecture overview

```
Internet (HTTPS :443)
        │
   ┌────▼────┐
   │  NGINX  │  ← only entrypoint, TLSv1.2/1.3
   └────┬────┘
        │ Port :9000
   ┌────▼──────────┐
   │  WordPress    │  ← php-fpm, no nginx
   │  + php-fpm    │
   └────┬──────────┘
        │ Port :3306
   ┌────▼────┐
   │ MariaDB │  ← database only
   └─────────┘
```

All three containers share a custom Docker bridge network called `inception`. Persistent data is stored in named Docker volumes mounted at `/home/bekinci-/data` on the host machine.

**Virtual Machines vs Docker**
VM runs a full OS so it is heavy. Docker is lighter because it only runs services. This project uses both: Docker runs inside a VM

**Secrets vs Environment Variables**
Environment variables are used for normal config values. Secrets are used for passwords and sensitive data.
For highly sensitive data—specifically the **MariaDB Root Password**, **MariaDB User Password**, and **WordPress Administrator Password**—**Docker Secrets** are implemented. These credentials are safely read from `/run/secrets/` inside the containers rather than being exposed in the runtime environment. Other standard user test passwords use environment variables to streamline automated setup via WP-CLI.

**Docker Network vs Host Network**
     **Bridge Network (default Docker network)**
          - Containers have their own private network
          - Each container gets its own IP address
          - Containers can talk to each other using IP or name
          - You must use port mapping to access from outside
     **Host Network**
          - Container uses the host machine’s network directly
          - No separate IP address for container
          - No need for port mapping
     **In this project**
          A custom bridge network is used instead of the default bridge or host network.
          All containers (like mariadb and wordpress) are connected to this private network called inception.
          This allows containers to communicate with each other using service names, while still keeping them isolated from the host machine and the outside world.

**Docker Volumes vs Bind Mounts**
In Docker, there are two main ways to save data:
1. **Bind Mount:** You connect a specific folder from your computer directly into the container.
2. **Named Volume:** Docker automatically creates and manages a secure space for your data.

To follow the project rules perfectly, this project uses a mix of both (**Hybrid Approach**). 

We create a **Named Volume**, but we use `driver_opts` with `o: "bind"` to force Docker to save all the files inside our exact paths:
- `/home/bekinci-/data/mariadb`
- `/home/bekinci-/data/wordpress`

This way, Docker completely manages our data, but the files are saved exactly where the project requires them on the host machine.

## Instructions

- A Virtual Machine running Debian:Bullseye(11)
- Docker and Docker Compose installed inside the VM
- `sudo` access for creating data directories

### Setup

1. Clone the repository inside your VM.

2. Add this line to /etc/hosts:
```
127.0.0.1   bekinci-.42.fr
```

3. Run the project:
```bash
make
```

This will create the required data directories and build and start all containers.

### Available make targets

| Command | Description |
|---|---|
| `make` | Build images and start all containers |
| `make down` | Stop and remove containers |
| `make clean` | Stop containers and remove all images and cache |
| `make fclean` | Full clean including volumes and persistent data |
| `make re` | Full clean and rebuild |

---

## Additional Technical Choice: 
**WP-CLI**
     In this project, WP-CLI (WordPress Command Line Interface) is used to manage WordPress.
     Instead of setting up WordPress manually through the web interface, WP-CLI allows us to install and configure WordPress using commands.
     With WP-CLI, we can:
          -Install WordPress automatically
          -Create the admin user
          -Set up the database connection
          -Configure WordPress without using the browser
     This makes the setup process faster, easier, and fully automated when the container starts.

**Native PID 1 Process Management (Avoiding CPU Bloat)**
     A common bad practice in Docker is using infinite loops like `tail -f /dev/null` or `while true; do sleep 1;` done as the main process of a container just to keep it running. This creates a fake background process that wastes host CPU cycles by constantly running without doing any real work.
     In this project, we explicitly avoid this. Every container runs its main service as **PID 1** in the foreground:
          - **NGINX:** Runs with `daemon off;`
          - **WordPress:** Runs `php-fpm` directly in the foreground.
          - **MariaDB:** Runs `mysqld_safe` as the primary process.
     By doing this, the containers stay alive naturally because Docker monitors the active foreground service. When there are no web requests or database connections, these services go into a "sleep mode" using Linux's internal logic. This means they use **0% CPU** when idle, making our project very light and efficient.

## Resources

### Documentation
- [Docker official documentation](https://docs.docker.com/)
- [What is Docker?](https://www.geeksforgeeks.org/devops/introduction-to-docker/)
- [Docker ile VM Arasındaki Fark Nedir?](https://aws.amazon.com/tr/compare/the-difference-between-docker-vm/)
- [Multiprocessing and PID 1 Issue in Docker](https://www.hawu.me/dev/6240)
- ["Docker Nedir Nasıl Kullanılır? | Part #1 | Image Nedir? Container Nedir? Docker Komutları"-kablosuzkedi / YouTube](https://www.youtube.com/watch?v=4XVfmGE1F_w&t=4298s)
- ["Docker Compose Kullanımı | Docker Compose Nedir"-Ömer Bektaş / YouTube](https://www.youtube.com/watch?v=poQJCPbzX_E)

### Tutorials
- [42 Inception guide by mcombeau](https://github.com/mcombeau/inception)
- [Inception project tips (grademe.fr)](https://tuto.grademe.fr/inception/)

### AI usage
Claude & Gemini was used during this project:
- Editing .md files and translating them to English
- Understanding why the kernel is lightweight and how it works
- Understanding how Docker works on Windows, macOS, and Linux
- Understanding configuration file syntax and commands(what is ini, TOML etc..)
- Understanding and analyzing errors
All AI-generated content was reviewed, tested, and understood before being included in the project.
