# Phoenix Template

A current Phoenix application starter using the DuskMoon web design system.

The template is based on Phoenix 1.8, LiveView 1.2, Bandit, Tailwind 4, and
DuskMoonBundler. It includes a database-ready Ecto setup, verified routes,
runtime production configuration, and an example product-oriented home page.

## Setup

* Install Elixir 1.18 or newer, Erlang/OTP, Node.js, and PostgreSQL.
* Run `mix setup` to fetch dependencies, create the database, and build assets.
* Start the development server with `mix phx.server`.
* Visit [http://localhost:4000](http://localhost:4000).

The development database defaults to `gsmlg_dev` with the local PostgreSQL
`postgres` user. Change the values in `config/dev.exs` for your environment.

## Assets and design

DuskMoon components, sunshine/moonlight themes, and Tailwind sources are wired
through DuskMoonBundler. Use semantic DuskMoon tokens such as `bg-primary`,
`bg-surface`, and `text-on-surface` when adding pages.

Run `mix assets.build` for a non-digested development build or
`mix assets.deploy` for a production build with hashed assets.

## Igniter

Igniter is included as a development/test-only dependency for project
transformations and generators supplied by compatible libraries. It is not part
of the production release and does not affect application startup. Run
`mix igniter.install <package>` when adding a library that provides an Igniter
installer.

## Production

Set `DATABASE_URL`, `SECRET_KEY_BASE`, and optionally `PHX_HOST`,
`PORT`, `POOL_SIZE`, and `DNS_CLUSTER_QUERY`. Build assets before creating a
release:

```sh
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release
PHX_SERVER=true _build/prod/rel/gsmlg/bin/gsmlg start
```

The legacy `restart_prod.sh` and Dockerfile are retained for compatibility
with existing deployments; new deployments should use the release commands
above and provide the runtime environment variables explicitly.

## Checks

```sh
mix precommit
mix assets.deploy
```
