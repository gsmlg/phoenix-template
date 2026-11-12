#!/bin/sh
# Compatibility wrapper around the release lifecycle, never raw PID files.
set -eu
release="${RELEASE_ROOT:-_build/prod/rel/gsmlg}/bin/gsmlg"
if [ ! -x "$release" ]; then
  echo "Build a production release first; see README.md." >&2
  exit 1
fi
case "${1:-}" in
  start) exec "$release" start ;;
  stop) exec "$release" stop ;;
  restart) exec "$release" restart ;;
  *) echo "Usage: $0 {start|stop|restart}" >&2; exit 2 ;;
esac
