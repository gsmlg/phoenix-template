# Build native dependencies on the same glibc distribution as the runtime.
FROM rust:1.99.1-bookworm AS rust
FROM hexpm/elixir:1.18.4-erlang-28.1-debian-bookworm-20260610-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential git ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
ENV PATH="/usr/local/cargo/bin:${PATH}" \
    RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo \
    VIZE_EX_BUILD=1 CARGO_BUILD_JOBS=2 MIX_ENV=prod
WORKDIR /app
# The published Hex 2.7 archive contains bytecode incompatible with OTP 28.
RUN git clone --depth 1 --branch v2.7.0 https://github.com/hexpm/hex.git /tmp/hex \
    && cd /tmp/hex && mix archive.build && mix archive.install hex-2.7.0.ez --force \
    && cd /app && rm -rf /tmp/hex && mix local.rebar --force
COPY mix.exs mix.lock ./
COPY scripts scripts
RUN elixir scripts/check_dependency_lock.exs
COPY config/config.exs config/prod.exs config/
RUN mix deps.get --only prod --check-locked && mix deps.compile
COPY lib lib
COPY priv priv
COPY assets assets
RUN mix assets.setup && mix assets.deploy && mix compile --warnings-as-errors
COPY config/runtime.exs config/
COPY rel rel
RUN mix release

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system app && useradd --system --gid app --home /app app
WORKDIR /app
COPY --from=build --chown=app:app /app/_build/prod/rel/gsmlg ./
USER app
ENV HOLOGRAM_ENV=prod PHX_SERVER=true PORT=4000
EXPOSE 4000
CMD ["/app/bin/gsmlg", "start"]
