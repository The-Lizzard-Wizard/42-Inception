# User documentation

This guide explains how to manage, access, and verify the multi-container web infrastructure running on this system.

## Stack Overview & Services Provided
The infrastructure consists of three core services, each running in an isolated Docker container within a private network:

- NGINX (Web Server & Reverse Proxy): The single entry point to the system. It handles incoming traffic on port 443 using encrypted TLS/SSL, serving static content and routing PHP requests.

- WordPress (Application Server): Executes the PHP codebase for the website using PHP-FPM and manages content, themes, and plugins.

- MariaDB (Database): A relational SQL database that securely stores all WordPress content, user accounts, and configuration settings.

[Browser/Client] ─(HTTPS: 443)─> [NGINX] ─(FastCGI: 9000)─> [WordPress] ─(SQL:3306 )─> [MariaDB]

## Start and stop the project

The projet can be entirely manipulated using the provided Makefile lacoated at the root of the repository.
* Launch image building and start the stack
```bash
make
```
* Stop the stack
```bash
make down
```

* Shutdown and cleanup
```bash
make clean
```

* Delete everything
```bash
make fclean
```




## Access the website and the administration panel.

Before accessing the site, ensure your host machine's /etc/hosts file maps 127.0.0.1 to your configured domain name. 

Once the infrastructure is started:

* Open the web browser and go to https://gchauvet.42.fr.

* Accept the warning related to auto-signed SSL certificate.

For testing the WordPress admin panel:

* URL : https://gchauvet.42.fr/wp-admin

## Locating and Managing Credentials
All sensitive configuration parameters and credentials are managed through environment variables stored in the .env file located inside the srcs/ directory (srcs/.env).

Credential Locations (srcs/.env)
Database Administrative Access:

- MYSQL_ROOT_PASSWORD — Root password for full MariaDB administration.

Database Application Access:

- MYSQL_DATABASE — Database name used by WordPress.

- MYSQL_USER — Username assigned to WordPress.

- MYSQL_PASSWORD — Password for the WordPress database user.

WordPress Super Administrator:

- ADMIN_USER — Administrator username.

- ADMIN_PASSWORD — Administrator password.

- ADMIN_EMAIL — Administrator email address.

WordPress Standard User:

- WP_USER — Regular author/subscriber username.

- WP_PASSWORD — Password for the regular user.

To update the credentials, you must edit the .env file and restart everything using `make re`.

## Checking Service Health & Status

Administrators can verify the operational status of the stack using the following commands:

- Verify Container Status
```bash
docker ps
```
- Monitor container logs
```bash
docker logs nginx
docker logs mariadb
docker logs wordpress
```
- Verify the persistent data storage
```bash
ls -la /home/$USER/data/mariadb
ls -la /home/$USER/data/wordpress
```


