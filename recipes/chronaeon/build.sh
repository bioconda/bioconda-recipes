#!/bin/bash
set -ex

${PYTHON} -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

# hf_xet (used by huggingface_hub at runtime for model weight downloads)
# builds its TLS client via rustls-native-certs, which only consults system
# certificate paths and SSL_CERT_FILE. Mulled containers have no CA bundle at
# any of those paths, so downloads fail with "Reqwest error: builder error".
# Point SSL_CERT_FILE at the conda ca-certificates bundle; mulled's
# env-activate.sh sources activate.d scripts before running the tool.
# A pre-existing SSL_CERT_FILE (e.g. an institutional proxy CA bundle)
# is left untouched.
mkdir -p "${PREFIX}/etc/conda/activate.d" "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<'EOF'
export SSL_CERT_FILE="${SSL_CERT_FILE:-${CONDA_PREFIX}/ssl/cacert.pem}"
EOF
cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<'EOF'
unset SSL_CERT_FILE
EOF
