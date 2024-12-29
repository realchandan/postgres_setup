# PostgreSQL Setup

I'm making my Postgres setup open source. This is what I use for self-hosting PostgreSQL myself.

It comes with a lot of room for customization and notably:

- Automatic SSL certificate generation/renewals with Traefik as a reverse proxy
- PgBouncer as a connection pooler that uses auth query instead of userlist.txt
- Automatic incremental backups to S3-compatible storage
- Script to create databases and users with granular, scoped permissions within the single cluster

I would like to hear your thoughts, suggestions, and recommendations regarding this setup, and if anything can be improved.

I want to keep this setup small and without bloatware. It can be used as is, but I expect it to be customized according to your needs.  
Current config files expect 4 GB of RAM. If you have less or more, change the settings in the postgres.conf file and the Docker Compose service memory limits.

Currently, tools to view Postgres are not added as part of the setup.  
You can access the database through psql or tools like [pgAdmin 4](https://github.com/pgadmin-org/pgadmin4), [Beekeeper Studio](https://github.com/beekeeper-studio/beekeeper-studio), or [DBeaver](https://github.com/dbeaver/dbeaver).

## Usage

**Assumptions:** You have a Linux server used solely for hosting PostgreSQL with Docker.

### Steps

1. `git clone https://github.com/realchandan/postgres_setup.git`

2. `cd postgres_setup`

3. Copy environment files:

   ```bash
   cp .env.example .env
   cp ./config/postgres.env.example ./config/postgres.env
   cp ./config/pgbackup.env.example ./config/pgbackup.env
   ```

   Then, modify the environment files with the appropriate values.

   Here's an explanation of environment variables:

   > **.env**  
   > | Variable Name | Explanation |
   > | --------------- | ---------------------------------------------------------------------------------- |
   > | ACME_EMAIL | The email to be used for ACME/LetsEncrypt |
   > | POSTGRES_DOMAIN | The domain where you want to host the database over SSL, e.g. postgres.example.com |

   > **./config/postgres.env**  
   > | Variable Name | Explanation |
   > | ----------------- | ------------------------------------------------------------------------------------------------- |
   > | POSTGRES_DB | The name of the default database. Ideally, you shouldn’t change it (by default, it's postgres). |
   > | POSTGRES_PASSWORD | The password of the PostgreSQL superuser (set a very strong one here). |
   > | POSTGRES_USER | The username of the superuser (ideally, don’t change it). |

   > **./config/pgbackup.env**  
   > Refer [here](https://github.com/realchandan/pgbackup?tab=readme-ov-file#usage). If you don't want backups, comment out the pgbackup service in the Docker Compose file.

4. Point your domain A/AAAA records to the server’s public IPv4/IPv6 addresses.

5. Allow ports 443 and 5432 (TCP) through the firewall. Depending on your firewall, steps may vary. Port 443 is needed for Let’s Encrypt TLS challenge, and 5432 is used by PgBouncer.

6. Add public permissions to the `./config/pg` folder with `chmod -R 777 ./config/pg`.

7. Run `docker compose --env-file .env up -d` to bring up all the services.

8. Create a new database using:

   ```bash
   docker exec -it postgres bash -c "/docker-entrypoint-initdb.d/create-user.sh awesome_db passw0rd"
   ```

   This command creates a user called `awesome_db_user` with the password `passw0rd` and gives them access to a database named `awesome_db`.

9. Enjoy and star this repo! (Helps me flex!)
