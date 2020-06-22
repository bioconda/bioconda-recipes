#!/bin/sh

# circumvent a bug in conda-build >=2.1.18,<3.0.10
# https://github.com/conda/conda-build/issues/2255
[[ -z $REQUESTS_CA_BUNDLE && ${REQUESTS_CA_BUNDLE+x} ]] && unset REQUESTS_CA_BUNDLE
[[ -z $SSL_CERT_FILE && ${SSL_CERT_FILE+x} ]] && unset SSL_CERT_FILE

cp -r "${SRC_DIR}/src/*.jl" "${PREFIX}/bin"
cp -r "${SRC_DIR}/scripts" "${PREFIX}"
cp "${SRC_DIR}/*.toml" "${PREFIX}/"
cat <<EOF > "${PREFIX}/bin/mentalist"
#!/usr/bin/env sh
exec julia --project='${PREFIX}' -- '${PREFIX}/src/MentaLiST.jl' "\$@"
EOF
chmod +x "${PREFIX}/bin/mentalist"

julia --project="${PREFIX}" -e 'using Pkg; Pkg.instantiate()'