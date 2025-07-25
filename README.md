# Metabase with Docker Compose

Run [Metabase](https://www.metabase.com/) with Docker and Docker Compose,
using PostgreSQL as application database.

Based on official docker images for [PostgreSQL] and [Metabase].

## Usage

- Clone this repository.

- Copy `.env.sample` to `.env` and adjust the variables.
- Use the provided script to reset and start the project from scratch:

  ```shell
  $ ./restart_project.sh
  ```

This script removes any previous containers and volumes before running `docker compose up` internally.

Metabase can connect to host (`host.docker.internal`) from static IP `172.16.200.30`,
(static IP can be used for authentication. e.g. in `pg_hba.conf`)

## References

https://www.metabase.com/docs/latest/operations-guide/running-metabase-on-docker.html
https://github.com/Cambalab/metabase-compose

[PostgreSQL]: https://hub.docker.com/_/postgres
[Metabase]: https://hub.docker.com/r/metabase/metabase