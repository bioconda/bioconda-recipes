set -euxo pipefail

if [[ -f src/Makefile ]]; then
  make -C src
else
  echo "No Makefile detected" >&2
  exit 1
fi

mkdir -p "${PREFIX}/bin"
if [[ -f src/raccess/run_raccess ]]; then
  install -m 0755 src/raccess/run_raccess "${PREFIX}/bin/raccess"
else
  echo "run_raccess not found after build"; ls -R; exit 1
fi