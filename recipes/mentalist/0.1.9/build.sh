#!/usr/bin/env sh

cp -r "${SRC_DIR}/src/*.jl" "${PREFIX}/bin"
cp -r "${SRC_DIR}/scripts" "${PREFIX}"
cp "${SRC_DIR}/*.toml" "${PREFIX}/"
cat <<EOF > "${PREFIX}/bin/mentalist"
#!/usr/bin/env sh
exec julia --project='${PREFIX}' -- '${PREFIX}/src/MentaLiST.jl' "\$@"
EOF
chmod +x "${PREFIX}/bin/mentalist"

julia --project="${PREFIX}" -e 'using Pkg; Pkg.instantiate()'