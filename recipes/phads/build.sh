#!/usr/bin/env bash
set -euxo pipefail

echo "PWD=${PWD}"
echo "PREFIX=${PREFIX}"
echo "PYTHON=${PYTHON}"
ls -la

"${PYTHON}" --version
"${PYTHON}" -m pip --version

test -f phads.py
test -d scripts
test -d database

if [[ -f pyproject.toml ]]; then
	"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv
else
	site_packages=$("${PYTHON}" -c 'import sysconfig; print(sysconfig.get_path("purelib"))')
	mkdir -p "${site_packages}" "${PREFIX}/bin"
	cp phads.py "${site_packages}/phads.py"
fi

if [[ ! -x "${PREFIX}/bin/phads" ]]; then
	mkdir -p "${PREFIX}/bin"
	cat > "${PREFIX}/bin/phads" <<'EOF'
#!/bin/sh
exec python -m phads "$@"
EOF
	chmod +x "${PREFIX}/bin/phads"
fi

mkdir -p "${PREFIX}/share/phads"
cp -R scripts "${PREFIX}/share/phads/"
cp -R database "${PREFIX}/share/phads/"

test -f "${PREFIX}/share/phads/scripts/predict_residue_pool_gate.py"
test -d "${PREFIX}/share/phads/database"
