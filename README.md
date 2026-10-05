*This project has been created as part of the 42 curriculum by gchauvet*

# Inception

![Debian](https://img.shields.io/badge/OS-Debian%20Bookworm-a81d24?style=for-the-badge&logo=debian&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![NGINX](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)

## Description

Inception is an system infrastructure project which aims to deploy a complete web stack (**NGINX**, **WordPress**, **MariaDB**) isolated in handmade Docker containers, orchestrated by Docker Compose under Debian Bookworm.

### Infrastructure architecture

All services works in a private Docker network (inception_network). NGINX is the only entrypoint exposed to the outside on the secured port 443 (HTTPS) with TLS v1.2 / v1.3.

```
               [ Client / Host Browser ]
                           │
                           │ HTTPS (Port 443 - TLS v1.2/v1.3)
                           ▼
┌─────────────────────────────────────────────────────┐
│  Container NGINX (Reverse Proxy & SSL)              │
└──────────────────────────┬──────────────────────────┘
                           │
                           │ FastCGI (Port 9000 -  Docker internal network)
                           ▼
┌─────────────────────────────────────────────────────┐
│  Container WordPress (PHP-FPM)                      │
└──────────────────────────┬──────────────────────────┘
                           │
                           │ SQL (Port 3306 - Docker internal network)
                           ▼
┌─────────────────────────────────────────────────────┐
│  Container MariaDB (Database)                       │
└─────────────────────────────────────────────────────┘
```

### Services Composition

All containers are built locally  based on a Debian Bookworm base image (no premade images from Docker Hub).

| Service | Base Image | Role / Description | Port(s) | Volume (Host persistance) |
| :--- | :--- | :--- | :--- | :--- |
| **NGINX** | `debian:bookworm` |  Web Server, Reverse Proxy & management of SSL certificate (TLS v1.2/v1.3) | **443** *(Exposed on Host)* | `/home/$USER/data/wordpress` |
| **WordPress** | `debian:bookworm` | PHP-FPM motor & auto-init of the website using `wp-cli` | **9000** *(Internal)* | `/home/$USER/data/wordpress` |
| **MariaDB** | `debian:bookworm` | Relational SQL database server for WordPress | **3306** *(Internal)* | `/home/$USER/data/mariadb` |

### Data persistance (Volumes)

Sensitive and persistant datas are directly saved on the host machine's hard drive  using Bind Mounts :

MariaDB Database: `/home/$USER/data/mariadb/var/libmysql` \
WordPress files: `/home/$USER/data/wordpress/var/www/html` 

## Project Description

### Virtual machines vs Docker

Virtual machines and Dockers serve different purposes. They are fundamentally different as explained below:

- Virtual machines are emulating virtual hardware (CPU, ram, disk) whereas Docker
containers are emulating an OS.

- Virtual machines uses a full on real OS install (Kernel and system utilities) that runs in a virtual environnement whereas a Docker container uses the kernel of the hosts machine for all system calls.

- Virtual machines are software level, meaning they are abstracted from the host's kernel whereas Docker containers are using the kernel and are isolated using namespaces and control groups

- Virtual machines uses a lot of ressources (lots of RAM), and has to boot an entire OS (slow) whereas a Docker container doesn't.

In the context of the project, you can tell both are very different because you are running a Debian virtual machine on the host machine to host Docker and make Docker containers to run MariaDB, WordPress and NGINX inside isolated kernel namespaces on that VM.

Virtual machine emulates a machine running an OS, whereas Docker containers emulates a process isolated in a container.

### Environement variables vs Secrets

Environement variables are text-file key-value pairs that are loaded into the container's environement.
They are advised to be used for non-sensitive config flags as they can be accessed in clear text by anyone who can use `docker inspect` or process monitoring or logs.

Docker secrets are sensitive data stored in a dedicated volume insidde of the container. They are never written to encrypted disk layers or process environements.
They are advised to be used for passwords, API tokens, private SSL keys or any sensitive data.

### Docker network vs Host network

A Docker network is an isolated software bridge with his own subnet and IP range that is isolated from the host's machine and outside world (unless specified otherwise using `ports:`). It provides internal DNS resolution for the services to communicate.

Using the host network (forbidden on this project) using `network_mode: "host"` removes the network isolation between the containers and the hosts machine entirely. It allows the containers to use the hosts network namespace, IP, and port space directly.

### Docker volumes vs Bind mounts

Docker volumes are managed directly by Docker within a dedicated host directory. They can't be modified by users, only via docker CLI. They are safer for production environement.

Bind mounts are directories on the host's machine that are directly mounted into the container file system.
They are accessible and modifiable by the host's user.

The project requires named Docker volumes with drivers configured to be pointing to `/home/$USER/data` for file visibility on the VM. 

## Instructions

### Host file configuration

Link local IP to the domain name on the host machine by editing the file /etc/hosts :
```bash
sudo echo "127.0.0.1 authomas.42.fr" >> /etc/hosts
```

### Environnement variable (.env)
Create a file srcs/.env based on required variables:

.env.exemple:
```code
DOMAIN_NAME=gchauvet.42.fr
SITE_TITLE=42-inception
MYSQL_DATABASE=wordpress
MYSQL_USER=mysql_gchauvet
MYSQL_PASSWORD=pass
MYSQL_ROOT_PASSWORD=pass_root
ADMIN_USER=staff
ADMIN_PASS=staff_pass
ADMIN_MAIL=gchauvet@student.42lyon.fr
WP_USER=gchauvet
WP_MAIL=gchauvet@student.42lyon.fr
WP_USER_PASS=wp_pass
```
### Use

The projet can be entirely manipulated using the provided Makefile lacoated at the root of the repository.
* Launch image building and start the infrastructure 
```bash
make
```

* Verify container status
```bash
docker ps
```
* Stop the containers
```bash
make stop
```

* Stop and delete the local containers
```bash
make down
```

* Delete everything
```bash
make fclean
```

* Rebuild the entire project
```bash
make re
```

Once the infrastructure is started:

* Open the web browser and go to https://gchauvet.42.fr.

* Accept the warning related to auto-signed SSL certificate.

For testing the WordPress admin panel:

* URL : https://gchauvet.42.fr/wp-admin

Admin User : Defined in file .env (WP_ADMIN_USER)\
Admin Password : Defined in file .env (WP_ADMIN_PASSWORD)

## Resources

### Docker & Docker Compose

[Docker Overview](https://docs.docker.com/get-started/docker-overview/) — Understanding the difference between an image, a container and Docker Daemon.

[Docker File Reference](https://docs.docker.com/reference/dockerfile) — Official doc about Dockerfile commands (ENTRYPOINT, CMD, RUN, COPY).

[Compose File Specification](https://docs.docker.com/reference/compose-file/) — To make the docker-compose.yml (build, volumes, networks, depends_on).

### NGINX & SSL/TLS

[NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html) — A basic introduction to nginx.

[Configuring HTTPS Servers (NGINX)](https://nginx.org/en/docs/http/configuring_https_servers.html) — SSL/TLS part, managing keys and certificate, make config file.

### WordPress & PHP-FPM

[WP-CLI Command Reference](https://developer.wordpress.org/cli/commands/) — Command list for wp-cli: wp core download, wp config create, and wp user create.

[PHP-FPM Configuration](https://www.php.net/manual/fr/install.fpm.configuration.php) — For understanding process's pools and why we need to listen = 9000.

### MariaDB

[MariaDB Server Documentation](https://mariadb.com/docs/) —  mariadb-install-db, init users/bases with SQL.

### AI usage

AI was used to find documentation, to help write this readme.
