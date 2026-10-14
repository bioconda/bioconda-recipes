#!/bin/bash
set -euo pipefail

# getITD ships as plain scripts (getitd.py and helpers) plus the default FLT3
# amplicon annotation in anno/. Install everything under share/ and expose each
# script via a thin launcher in bin/. The hardcoded $PREFIX in the launchers is
# rewritten by conda's prefix-replacement at install time.

TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p "${TARGET}" "${PREFIX}/bin"

cp getitd.py getitd_from_config_wrapper.py make_getitd_config.py "${TARGET}/"
cp -r anno "${TARGET}/"

# bin-name:script-name pairs
for pair in \
    "getitd:getitd.py" \
    "getitd_from_config_wrapper:getitd_from_config_wrapper.py" \
    "make_getitd_config:make_getitd_config.py" ; do
    name="${pair%%:*}"
    script="${pair##*:}"
    launcher="${PREFIX}/bin/${name}"
    cat > "${launcher}" <<EOF
#!/bin/bash
exec python "${TARGET}/${script}" "\$@"
EOF
    chmod +x "${launcher}"
done
