---
publishDate: "2021-08-12"
toc: true
title: Postgres Physical Replication
image: /images/replication.jpg
tags: [Tutorials, PostgreSQL, Replication, Docker, Database, HighAvailability]
excerpt: Learn how to set up physical replication in PostgreSQL using Docker containers to ensure high availability and redundancy.
---
Enabling Physical Replication in PostgreSQL  Physical replication in PostgreSQL allows you to create a replica of your primary database instance, providing high availability and redundancy. This guide will walk you through the steps to set up physical replication using Docker containers. The use of containers is for ease of use. These steps can be recreated using various Postgres instance types.

## Run a Docker PostgreSQL Container as the Primary Instance

First, create a Docker network for communication between containers:

```bash
docker network create pg-network
```

Now, run the primary PostgreSQL instance:

```bash
docker run \
  --name db-primary \
  --volume ${PWD}/postgres-docker/db-primary:/var/lib/postgresql \
  --publish 54321:5432 \
  --env POSTGRES_USER=postgres \
  --env POSTGRES_PASSWORD=postgres \
  --net=pg-network \
  --detach postgres:latest
```

### Command Breakdown

`--name db-primary`:
This option names the container db-primary. Naming containers makes it easier to manage and reference them later.

`--volume ${PWD}/postgres-docker/db-primary:/var/lib/postgresql`:

This mounts a volume from the host machine to the container. ${PWD}/postgres-docker/db-primary is a directory on the host machine, and /var/lib/postgresql is where PostgreSQL stores its data inside the container. It ensures data persistence even if the container is stopped or removed.

`--publish 54321:5432`:

This maps port 54321 on the host machine to port 5432 in the container. Port 5432 is the default port for PostgreSQL. Mapping it to 54321 on the host avoids conflicts with any other PostgreSQL instances that might be running.

`--env POSTGRES_USER=postgres`:

This sets an environment variable POSTGRES_USER with the value postgres. It specifies the username for the PostgreSQL database.

`--env POSTGRES_PASSWORD=postgres`:

This sets an environment variable POSTGRES_PASSWORD with the value postgres. It specifies the password for the PostgreSQL database user.

`--net=rideshare-net`:

This connects the container to a user-defined network called rideshare-net. Docker networks allow containers to communicate with each other easily.

`--detach`:

This runs the container in the detached mode. The terminal is free to be used for other commands.

`postgres:latest`:

This specifies the image to use for the container. In this case, it's the latest version of PostgreSQL.

###  Configuring the Primary Database
In this section, we will configure the primary database to use logical write-ahead logging (wal). You should be able to connect to the primary db by using the following command:

`psql postgres://postgres:postgres@localhost:54321/postgres`

In the psql console, check the location of the config file.

```psql
show config_file;
```

Using the path of the config file, cp the file to your host so that it can be edited. It's a good idea to create a backup of the original file, make sure to create one in rollback is needed.

```bash
# copy the conf file to the host
docker cp db-primary:/var/lib/postgresql/data/postgresql.conf .

# create the backup
cp postgresql.conf postgresql.conf-backup
```

In the postgresql.conf file, enable wal by adding the following in the Write Ahead Log section:

```config
wal_level = logical
```
Now, copy the file back to the file, restart the database, and check the wall level:

```bash
docker cp postgresql.conf db-primary:/var/lib/postgresql/data/.
docker restart db-primary
docker exec --user postgres -it db-primary psql -c "SHOW wal_level"
```
The last command should show:

```
wal_level
-----------
 logical
(1 row)txt
```


We are choosing logical because it covers both physical and logical replication. That way you can use these containers if you choose to use logical later.

## Adding a Replica User

In this section, we'll create the necessary users to use replication. We will need a PostgreSQL user with LOGIN and REPLICATION privileges on the primary database. This user will be created and used to initiate replication from replica instances.


### Creating the Replica

First, let's create the replica db by using the following command:

```bash
docker run --name db-replica \
--volume ${PWD}/postgres-docker/db-replica:/var/lib/postgresql/data \
--publish 54322:5432 \
--env POSTGRES_USER=postgres \
--env POSTGRES_PASSWORD=postgres \
--net=pg-network \
--detach postgres:latest
```

The following steps are a bit complicated, so I wrote a script to automate the process:

```bash
#!/bin/bash
#
# Purpose:
# - Generate password
# - store it in .pgpass
# - Create replication_user using generated password, on db-primary
# - Copy .pgpass to db-replica
#
# The .pgpass password is used to authenticate replication_user,
# when they run pg_basebackup
#
# Make sure db-primary and db-replica are running
#
running_containers=$(docker ps --format "{{.Names}}")
if echo "$running_containers" | grep -q "db01"; then
    echo "db 1 is running...continuing" else
echo "db 1 is not running" echo "Exiting."
exit 1
fi

if echo "$running_containers" | grep -q "db02"; then echo "db02 is    running...continuing"
else
echo "db02 is not running" echo "Exiting."
exit 1
fi

# Password for replication_user
export REP_USER_PASSWORD=$(openssl rand -hex 12) echo "Create REP_USER_PASSWORD for replication_user" echo $REP_USER_PASSWORD
# "rm replication_user.sql" for a clean starting point # CREATE USER statement as SQL file
# Set password to DB_PASSWORD value
rm -f replication_user.sql
echo "CREATE USER replication_user
WITH ENCRYPTED PASSWORD '$REP_USER_PASSWORD'
 report erratum • discussREPLICATION LOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public
TO replication_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO replication_user;" >> replication_user.sql
rm -f .pgpass
echo "*:*:*:replication_user:$REP_USER_PASSWORD" >> .pgpass
# Copy replication_user.sql to db 1
docker cp replication_user.sql db 1:.
echo "Copy .pgpass, chown, chmod it for db 2" # Copy .pgpass to db 2 postgres home dir docker cp .pgpass db-replica:/var/lib/postgresql/. docker exec --user root -it db-replica \
chown postgres:root /var/lib/postgresql/.pgpass docker exec --user root -it db-replica \
  chmod 0600 /var/lib/postgresql/.pgpass
# Create replication_user on db01
docker exec -it db-primary \ psql -U postgres \
-f /replication_user.sql
```
Create a file with the code above and run it.  The script does the following:
- Ensures that both databases are running.
- Generates a password.
- Assigns the password to an env variable.
- Creates the file replication_user.sql, with CREATE USER SQL commands to create the replication user.
- Assigns the generated password to replication_user.
- The SQL file is copied to db-primary so it can be run there.
- The generated password is placed in a .pgpass file.
- The .pgpass file is copied to db-replica.
- Finally, the script will allow replication_user to connect from db02 to db01 using password authentication.

If everything went ok, you will see output like this:
```bash
db01 is running...continuing
db02 is running...continuing
Create REP_USER_PASSWORD for replication_user
<SOME HASH VALE>
Successfully copied 2.05kB to db-primary:.
Copy .pgpass, chown, chmod it for db-replica
Successfully copied 2.05kB to db02:/var/lib/postgresql/.
```

If for some reason you need to redo the steps, you can tell docker to stop the psql instances and rm them to start over.


## Granting Access To Replica User

In this section, we'll grant access to the replica user using the [pg_hba.conf](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) file. See where that file is located using this command:

```shell
docker exec --user postgres -it db-primary  psql -c "SHOW hba_file"`
```
The output should be ` /var/lib/postgresql/data/pg_hba.conf` unless there was some customization done by yourself. We'll be using the hba path shortly.

Now, let's look up the IP of db 2. Use the following command:

`docker container inspect db-replica  | grep "IPAddress"`

The output should be something like
```sh
"SecondaryIPAddresses": null,
  "IPAddress": "",
    "IPAddress": "172.18.0.2",
```

Now, copy the hba file locally and add the following line.

```txt
# TYPE  DATABASE        USER             ADDRESS                 METHOD
host    replication     replication_user 172.18.0.3/32           md5
```
Copy it back and reload the db.

```bash

docker cp db01:/var/lib/postgresql/data/pg_hba.conf .
cp postgresql.conf pb_hba.conf-backup
vim pg_hba.conf # add your ip address
docker exec --user postgres -it db-primary  psql -c "SELECT pg_reload_conf();"
docker cp pg_hba.conf db-primary:/var/lib/postgresql/data/.
```


If everything went well, you should be able to access db1 from db2:

```bash
docker exec --user postgres -it db-replica /bin/bash
psql postgres://replication_user:@db-primary/postgres
```


### Creating a Replication Slot
In this section we create a replication slot. What is a replication slot?
From the postgres docs:

```
A replication slot has an identifier that is unique across all databases in a PostgreSQL cluste. Slots persist independently of the connection using them and are crash-safe. A logical slot will emit each change just once in normal operation.
```
Essentially, it maintains data consistency and reliability in a replication setup by keeping track of what data changes have been sent and acknowledged by the replicas.

To create a replication slot, run the following command:
```bash
PGPASSWORD=postgres docker exec -it db-primary \
psql -U postgres -c \
"SELECT PG_CREATE_PHYSICAL_REPLICATION_SLOT('db_rep_slot');"
```

## Creating the First Backup
With the replication slot created, we will create a db backup so that db2 can use it. We will remove the data in db2 and use the backup from db1 for db2. This ensures that the data on both databases match.

Run the following command:
```bash
docker exec --user postgres -it db02 /bin/bash
rm -rf /var/lib/postgresql/data/* &&  pg_basebackup --host db01 --username replication_user --pgdata /var/lib/postgresql/data --verbose --progress --wal-method stream --write-recovery-conf --slot=db_rep_slot
exit
docker restart db-replica
```

Chec the logs using `docker logs db-replica`. You should see something like this:

```txt
LOG:  started streaming WAL from primary at 0/8000000 on timeline 1
LOG:  restartpoint starting: time
```

## Configuring the Replica

So far, we configured db1 for replication and gave db2 access to db1. In this section, we will configure db2 for replication.


## Testing Setup

You can test your setup by creating a db on db1 and then querying for data in db2.

``` sh
docker exec --user postgres -it db-primary /bin/bash
psql

# in psql console
CREATE DATABASE testing
\c testing
create table replica_test ( name VARCHAR(15) ) ;
insert into testing (name) values ('first test);
```

Now, see if if db2 has the changes.

```sh
docker exec --user postgres -it db02 /bin/bash
psql
# in psql
\c testing
select * from replica_test
```

You should be able to see the data from db1. Congratulations! you now have a replicated postgres database.
# References
1. [Host Based Authentication](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html)

2. [ Write Ahead Log ](https://www.postgresql.org/docs/current/wal-intro.htmlx)
https://medium.com/@eremeykin/how-to-setup-single-primary-postgresql-replication-with-docker-compose-98c48f233bbf



