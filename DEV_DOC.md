# Developer documentation

This documentation provides step-by-step instructions for developers to set up, build, manage, and debug the Inception infrastructure from source.

## Environment Setup & Prerequisites

### Prerequisites

Ensure your development environment meets the following requirements:

- Operating System: Linux (Debian/Ubuntu recommended) or macOS.

- Core Packages: `docker.io`, `docker-compose-v2` (or docker compose plugin), `make`, `git`, and `curl`.

- Sudo/Root Access: Required to manage host network routing and target directory creation.

### Repository Structure
```
.
├── Makefile 
└── srcs/
    ├── .env(.exemple)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/      --> Dockerfile, conf/, tools/
        ├── nginx/        --> Dockerfile, conf/, tools/
        └── wordpress/    --> Dockerfile, conf/, tools/
```

### Initial Configuration & Secrets Setup

- Link local IP to the domain name on the host machine by editing the file /etc/hosts :
```bash
sudo echo "127.0.0.1 authomas.42.fr" >> /etc/hosts
```

- Create srcs/.env with your deployment secrets (look at /srcs/.env.example).

## Build and launch the project

The project build pipeline is orchestrated via the root Makefile and srcs/docker-compose.yml.

### Build Pipeline Steps
- Executes host system prep (creates bind-mount directories at /home/$USER/data).

- Triggers `docker compose -f $(DOCKER_COMPOSE_FILE) up -d --build` to compile images from local Dockerfiles.

- Initializes the internal bridge network (inception_network).

- Attaches persistent storage and boots services in detached mode.

### Build command

```bash
make
```
## Container & Volume Management Commands

Use these standard commands during development to manage and inspect running services:

* Launch image building and start the infrastructure 
```bash
make
```
* Stop the containers
```bash
make down
```
* Stop and delete the local containers
```bash
make clean
```
* Delete everything
```bash
make fclean
```
* Rebuild the entire project
```bash
make re
```

And use those for debugging and inspecting:

- View active container processes and health
```bash
docker ps
```
- Inspect container network assignments and bridge IPs
```bash
docker network inspect inception_network
```

- Tail container logs in real-time
```bash
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

- Open an interactive shell inside a running container
```bash
docker exec -it wordpress bash
docker exec -it mariadb bash
docker exec -it nginx sh
```
## Data Storage and Persistence Architecture

Data persistence is decoupled from container lifecycles using Bind Mounts connected directly to the host filesystem.

| Host Filesystem | Container Target |
| :--- | :--- |
|/home/$USER/data/mariadb | /var/lib/mysql (MariaDB container)|
|/home/$USER/data/wordpress | /var/www/html (WordPress & NGINX)|

- Database State: MariaDB writes database tables to /var/lib/mysql. Because this target maps to /home/$USER/data/mariadb, all schema updates and post entries persist even if the container is removed (docker rm).

- Shared Web Files: WordPress files stored in /var/www/html are mapped to /home/$USER/data/wordpress. This same volume is mounted inside both the wordpress container (to execute PHP scripts) and the nginx container (to serve static assets).

To wipe persistent data during development, remove the host mount contents:
```bash
sudo rm -rf /home/$USER/data/mariadb/*
sudo rm -rf /home/$USER/data/wordpress/*
```