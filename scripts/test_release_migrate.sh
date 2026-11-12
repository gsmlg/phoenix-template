#!/bin/sh
# Dependency-independent command contract. Does not claim a database smoke test.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/release with spaces/bin" "$tmp/elsewhere"
cp "$root/rel/overlays/bin/migrate" "$tmp/release with spaces/bin/migrate"
test -x "$tmp/release with spaces/bin/migrate"
cat > "$tmp/release with spaces/bin/gsmlg" <<'LAUNCHER'
#!/bin/sh
set -eu
[ "$#" -eq 2 ]
[ "$1" = eval ]
[ "$2" = 'Gsmlg.Release.migrate()' ]
exit "${MOCK_EXIT:-0}"
LAUNCHER
chmod +x "$tmp/release with spaces/bin/gsmlg"
cd "$tmp/elsewhere"
"$tmp/release with spaces/bin/migrate"
set +e
MOCK_EXIT=17 "$tmp/release with spaces/bin/migrate"
code=$?
set -e
[ "$code" -eq 17 ]
set +e
"$tmp/release with spaces/bin/migrate" unexpected >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ]
echo 'Release migrate command contract passed (not a database migration test).'
