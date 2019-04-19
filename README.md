![flyway](https://user-images.githubusercontent.com/33935506/40938269-afdc99c8-6841-11e8-9e11-860bf2e50596.png)

# Flyway README

This is a repository that consists of a collection of examples that illustrate how to use Flyway in terms of SQL migrations.

---

## Technology Used

* [Visual Studio Code](https://code.visualstudio.com/)

  Visual Studio Code is a source code editor developed by Microsoft for Windows, Linux and macOS. It includes support for debugging, embedded Git control, syntax highlighting, intelligent code completion, snippets, and code refactoring.

* [Docker](https://www.docker.com)

  Docker is a computer program that performs operating-system-level virtualization also known as containerization. It is developed by Docker, Inc.

* [Docker-Compose](https://docs.docker.com/compose/overview/)

  Compose is a tool for defining and running multi-container Docker applications.

* [SQL Server](https://www.microsoft.com/pt-br/sql-server)

  SQL Server is an object-relational database management system.

* [Flyway](https://flywaydb.org/)

  Flyway is an open source database migration tool.

---

## Environment Setup

You should have _Docker_ and _Docker-Compose_ installed. This can be verified by running the following commands from the command line.

* To verify Docker:

  ```bash
  docker version
  docker info
  docker run hello-world
  ```

* To verify Docker-Compose:

  ```bash
  docker-compose --version
  ```

If all is well, the above commands should have run flawlessly.

### Get Repository

There are 3 ways to get the repository for this guide:

1. Clone Repo Using HTTPS

   ```bash
   git clone https://github.com/davidemetrio/flyway.git
   ```

1. Clone Repo Using SSH

   ```bash
   git clone git@github.com:davidemetrio/flyway.git
   ```

1. Download Zip File

   ```bash
   wget https://github.com/davidemetrio/flyway/archive/master.zip
   unzip ./master.zip
   ```

### Initialise Environment

* Navigate to the _'flyway'_ directory using the command line.

* Once inside the _flyway_ directory, you will notice a file called _'docker-compose.yml'_. This file contains all the instructions required to initialise our environment with all the required containerised software. In our case, the _docker-compose.yml_ files holds the instructions to run _postgresql_ and _pgadmin_ containers.

* Type the following command to initialise environment to run Flyway code migrations:

  ```bash
  docker-compose up
  ```

* Type the following command to verify that there are 2 containers running. One container will be our PostgreSQL server. The second container will be our pgAdmin web application.

  ```bash
  docker-compose ps
  ```

  The above command should display the running containers as specified in the _docker-compose_ file.

---

## Create Database

The first thing to be aware of when creating a migration, is that migrations do not create databases. Migrations only apply within the context of a database and do not create the database itself. Therefore, for my demonstration I will create an empty database from scratch and then create migrations for that database.

In this example, I create a database called _"heroes"_. It is a database that stores data related to, you guessed it, heroes.

* At this point, you should have a running SQL Server container instance. To verify this, run the following command:

  ```bash
  docker-compose ps
  ```

---

## Create Migrations

For clarity sake, please take note that a migration is nothing more than a SQL file consisting of various SQL operations to be performed on the database.

### Understanding The Migrations

The _heroes_ database now exists. We are now ready to run our migrations. Please take note of the _migrations_ folder that is part of the repo for this example. The _migrations_ folder consists of 7 migrations that are briefly described as follows:

* V1_1__Create_hero_schema.sql - Creates a new _hero\_data_ schema

  ```sql
  CREATE SCHEMA hero_data AUTHORIZATION postgres;
  ```

* V1_2__Create_hero_table.sql - Create a new _hero_ table in the _hero\_data_ schema

  ```sql
  CREATE TABLE hero_data.hero
  (
      id BIGSERIAL NOT NULL,
      name VARCHAR(250) NOT NULL,
      description TEXT NOT NULL,
      debut_year INT NOT NULL,
      appearances INT NOT NULL,
      special_powers INT NOT NULL,
      cunning INT NOT NULL,
      strength INT NOT NULL,
      technology INT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
  );

  ALTER TABLE hero_data.hero ADD CONSTRAINT pk_hero_id PRIMARY KEY (id);
  ```

* V1_3__Add_Destroyer_hero.sql - Inserts our first hero into _hero_ table

  ```sql
  INSERT INTO hero_data.hero (
      name,
      description,
      debut_year,
      appearances,
      special_powers,
      cunning,
      strength,
      technology,
      created_at,
      updated_at) VALUES (
      'Destroyer',
      'Created by Odin, locked in temple, brought to life by Loki',
      1965,
      137,
      15,
      1,
      19,
      80,
      now(),
      now());
  ```

* V1_4__Create_user_schema.sql - Create a _user\_data_ schema

  ```sql
  CREATE SCHEMA user_data AUTHORIZATION postgres;
  ```

* V1_5__Create_user_table.sql - Create a new _user_ table in the _user\_data_ schema

  ```sql
  CREATE TABLE user_data.user
  (
      id BIGSERIAL NOT NULL,
      first_name VARCHAR(250) NOT NULL,
      last_name VARCHAR(250) NOT NULL,
      email VARCHAR(250) NOT NULL,
      alias VARCHAR(250) NOT NULL,
      created_at TIMESTAMPTZ NOT NULL,
      updated_at TIMESTAMPTZ NOT NULL
  );
  
  ALTER TABLE user_data.user ADD CONSTRAINT pk_user_id PRIMARY KEY (id);
  ```

* V1_6__Add_unique_hero_name_contraint.sql - Alter _hero_ table by adding a unique name constraint

  ```sql
  ALTER TABLE hero_data.hero ADD CONSTRAINT uk_hero_name UNIQUE (name);
  ```

* V1_7__Add_unique_user_email_constraint.sql - Alter _user_ table by adding a unique email constraint

  ```sql
  ALTER TABLE user_data.user ADD CONSTRAINT uk_user_email UNIQUE (email);
  ```

You will have noticed the strange naming convention. The way we name a migrations is as follows:

[According to the official Flyway documentation](https://flywaydb.org/documentation/migrations#naming), the file name consists of the following parts:

![flyway-naming-convention](https://user-images.githubusercontent.com/33935506/40931818-bc78fb5a-682c-11e8-90ce-cb9f8d0e8c95.png)

* **Prefix:** V for versioned migrations, U for undo migrations, R for repeatable migrations
* **Version:** Underscores (automatically replaced by dots at runtime) separate as many parts as you like (Not for repeatable migrations)
* **Separator:** __ (two underscores)
* **Description:** Underscores (automatically replaced by spaces at runtime) separate the words

### Run Migrations

Finally we get to run our migrations. To run the migrations, we will execute the [_Flyway_ Docker container](https://hub.docker.com/r/boxfuse/flyway/). 

Before running the migration, we need to obtain the IP address of the postgres container as follows:

```bash
docker container inspect -f "{{ .NetworkSettings.Networks.flyway_skynet.IPAddress}}" flyway_mssql-dev_1
```

We plug the obtained IP address from above into the command below. In my case, my IP address is _172.20.0.2_

```bash
docker run --rm --network flyway_skynet -v $PWD/mssql:/flyway/sql boxfuse/flyway -user=sa -password=P@ssword -url="jdbc:sqlserver://172.20.0.2:1433;databaseName=master" migrate
```

You should see an output similar to the following output:

![flyway-migration-result](https://user-images.githubusercontent.com/33935506/40933249-2e5510b6-6831-11e8-8df5-526f6c191434.png)

As can be seen from output above, all 7 migrations ran successfully.

---
