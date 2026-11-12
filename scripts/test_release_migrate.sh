#!/bin/sh
# Dependency-independent CLI contract; not a database migration smoke test.
set -eu
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/release with spaces/bin" "$tmp/elsewhere"
cp "$root/rel/commands/gsmlg" "$tmp/release with spaces/bin/gsmlg"
cp "$root/rel/overlays/bin/migrate" "$tmp/release with spaces/bin/migrate"
cat > "$tmp/release with spaces/bin/gsmlg.runtime" <<'LAUNCHER'
#!/bin/sh
set -eu
printf '%s\n' "$@" > "$CALL_LOG"
[ "$RELEASE_PROG" = gsmlg ]
exit "${MOCK_EXIT:-0}"
LAUNCHER
chmod +x "$tmp/release with spaces/bin/gsmlg.runtime"
export CALL_LOG="$tmp/call.log"
cli="$tmp/release with spaces/bin/gsmlg"
cd "$tmp/elsewhere"
for arg in help -h --help; do
  "$cli" "$arg" > "$tmp/help"
  grep -q 'migrate' "$tmp/help"
  grep -q 'daemon' "$tmp/help"
done
"$cli" > "$tmp/help"
test ! -e "$CALL_LOG"
"$cli" migrate
printf '%s\n' eval 'Gsmlg.Release.migrate()' > "$tmp/expected"
cmp "$CALL_LOG" "$tmp/expected"
"$tmp/release with spaces/bin/migrate"
cmp "$CALL_LOG" "$tmp/expected"
for command in start daemon stop version; do
  "$cli" "$command" 'argument with spaces'
  printf '%s\n' "$command" 'argument with spaces' > "$tmp/expected"
  cmp "$CALL_LOG" "$tmp/expected"
done
for command in start daemon migrate; do
  set +e
  MOCK_EXIT=17 "$cli" "$command"
  code=$?
  set -e
  [ "$code" -eq 17 ]
done
set +e
"$cli" migrate unexpected >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ]
echo 'Release CLI help, dispatch and exit-status contracts passed.'
