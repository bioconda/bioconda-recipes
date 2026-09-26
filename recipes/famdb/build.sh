#!/bin/bash

FDB_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"

mkdir -p "${FDB_DIR}"
mkdir -p "${PREFIX}/bin"

cp -a . "${FDB_DIR}/"
chmod +x "${FDB_DIR}/famdb.py"

cat > "${PREFIX}/bin/famdb.py" << EOF
#!/bin/bash
exec "${FDB_DIR}/famdb.py" "\$@"
EOF
chmod +x "${PREFIX}/bin/famdb.py"

for name in "${FDB_DIR}"/utils/*; do
    script_name="$(basename "$name")"
    cat > "${PREFIX}/bin/${script_name}" << EOF
#!/bin/bash
exec "${FDB_DIR}/utils/${script_name}" "\$@"
EOF
    chmod +x "${PREFIX}/bin/${script_name}"
done
