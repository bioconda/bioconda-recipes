#!/bin/bash

set -o pipefail

pip install . -vv

mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/Yleaf" << 'EOF'
#!/bin/bash
exec python -m yleaf "$@"
EOF
chmod +x "${PREFIX}/bin/Yleaf"