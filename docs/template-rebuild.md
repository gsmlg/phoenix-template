# Template rebuild

## Baseline

Preserve the `Gsmlg` application identity while replacing obsolete Yarn,
application-specific container images, port-80 defaults, baked-in Erlang cookies,
and raw PID lifecycle scripts with a standard Mix release.

Phoenix and LiveView remain the default server-rendered interface. DuskMoon
Hologram adds a separate browser-side Elixir example. Both use DuskMoon Bundler
and the same stylesheet. No authentication, tenant model, or business domain is
invented for the template.

## Deployment migration

Existing deployments must move configuration into environment variables, use
port 4000 behind their ingress, and explicitly run `Gsmlg.Release.migrate/0`.
The compatibility script no longer starts detached Mix or manages PID files.
No production data migration or deployment is performed by changing this template.

The runtime image and builder use the same glibc distribution. Vize is built
from source because its published 10.1.6 Linux NIF requires glibc 2.43. Rust is
only in the builder. Hex 2.7.0 is built from its official tag to avoid its
published archive's incompatible OTP bytecode.

## Verification boundaries

Run formatting, tests, production assets, release creation, and the Docker
build before rollout. Confirm both the LiveView and Hologram pages in a browser.
Unit tests of Hologram actions alone do not verify browser compilation or routing.
CI definitions are checks to run, not a claim of successful execution.

The application npm lock has dependency integrity tests, but its current audit
is blocked by package-registry network access. In addition, Hologram's published package currently
omits its internal JavaScript lock. Treat full build reproducibility as an
upstream issue until that package publishes and consumes a frozen lockfile.
