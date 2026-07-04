# flirt-infra

Local infrastructure for Flirt (Signalix-style layout): Docker Compose with
Postgres, **Flyway migrations**, Redis, adminer, and the API.

## Layout

```text
docker-compose.yml   # postgres → flyway (migrate) → redis → api → adminer
env/                 # *.env per service (.example committed, real files ignored)
scripts/             # up.sh · down.sh · migrate.sh · logs.sh
```

Migrations live in `../Flirt-api/migrations/` as Flyway versioned SQL
(`V1__init.sql`, `V2__*.sql`, …) and are mounted read-only into the Flyway
container. The API only starts after `flyway migrate` completes successfully.

## Usage

```bash
./scripts/up.sh          # bootstrap env files + start everything
./scripts/migrate.sh     # run pending migrations against running postgres
./scripts/logs.sh api    # tail a service's logs
./scripts/down.sh        # stop (add -v for a fresh database)
```

| Service | URL |
|---|---|
| API | http://localhost:3000 |
| Adminer (DB UI) | http://localhost:8080 (server `postgres`, user `flirt`) |
| Postgres | localhost:5432 |
| Redis | localhost:6379 |

## Adding a migration

1. Create `Flirt-api/migrations/V<next>__short_name.sql`
2. `./scripts/migrate.sh`
3. Update `flirt-docs/DATABASE_SCHEMA.md`

Never edit an applied migration — Flyway checksums will fail. Add a new one.
