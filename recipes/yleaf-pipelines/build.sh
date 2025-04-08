#!/bin/bash

set -o pipefail

pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/Yleaf" << 'EOF'
#!/bin/bash
exec python -m yleaf "$@"
EOF
chmod +x "${PREFIX}/bin/Yleaf"
