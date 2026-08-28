#!/usr/bin/env bash
set -euo pipefail
install -Dm644 cli.py "$PREFIX/lib/acvirus/cli.py"
for command in ACVirus acvirus; do
  install -Dm755 /dev/stdin "$PREFIX/bin/$command" <<"EOF"
#!/usr/bin/env bash
set -euo pipefail
script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
prefix="$(dirname -- "$script_dir")"
exec "$prefix/bin/python" "$prefix/lib/acvirus/cli.py" "$@"
EOF
done
