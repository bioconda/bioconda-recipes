#!/usr/bin/env bash
set -euo pipefail
# Install into share/ so this package does not clash with the `comebin`
# package's run_comebin.sh / gen_cov_file.sh; only prefixed entry points go on PATH.
share="${PREFIX}/share/${PKG_NAME}"
mkdir -p "${share}" "${PREFIX}/bin"
cp -r COMEBin auxiliary LICENSE.txt NOTICE.md "${share}/"
chmod a+x "${share}"/auxiliary/*.pl "${share}/COMEBin/run_comebin.sh" "${share}/COMEBin/comebin-llmopt" \
    "${share}/COMEBin/scripts/gen_cov_file.sh" "${share}/COMEBin/scripts/print_comment.py"
ln -s "../share/${PKG_NAME}/COMEBin/comebin-llmopt" "${PREFIX}/bin/comebin-llmopt"

# gen_cov_file.sh finds its helpers via `dirname $0`, so call it through a
# wrapper (not a symlink) to keep $0 pointing into share/.
cat > "${PREFIX}/bin/comebin-llmopt-gen-cov" <<'EOF'
#!/usr/bin/env bash
exec bash "$(dirname "$(readlink -f "$0")")/../share/comebin-llmopt/COMEBin/scripts/gen_cov_file.sh" "$@"
EOF
chmod a+x "${PREFIX}/bin/comebin-llmopt-gen-cov"
