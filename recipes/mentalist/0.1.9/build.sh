#!/usr/bin/env sh

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
echo "#!/usr/bin/env sh\nexport LAST_JULIA_DEPOT_PATH=\$JULIA_DEPOT_PATH\nexport JULIA_DEPOT_PATH='${PREFIX}/deps/'" > "${PREFIX}/etc/conda/activate.d/mentalist-activate.sh"
echo "#!/usr/bin/env sh\nexport LAST_JULIA_DEPOT_PATH=\nexport JULIA_DEPOT_PATH=\$LAST_JULIA_DEPOT_PATH" > "${PREFIX}/etc/conda/deactivate.d/mentalist-deactivate.sh"
chmod +x "${PREFIX}/activate.d/*" "${PREFIX}/deactivate.d/*"

cp -r "${SRC_DIR}/src/*.jl" "${PREFIX}/bin"
cp -r "${SRC_DIR}/scripts" "${PREFIX}"
cp "${SRC_DIR}/*.toml" "${PREFIX}/"
echo "#!/usr/bin/env sh\nexec julia --project='${PREFIX}' -- '${PREFIX}/src/MentaLiST.jl' \"\$@\"" > "${PREFIX}/bin/mentalist"
chmod +x "${PREFIX}/bin/mentalist"

JULIA_DEPOT_PATH="${PREFIX}/deps/" julia --project="${PREFIX}" -e 'using Pkg; Pkg.instantiate()'