#!/bin/bash

set -o pipefail

# Install the package
pip install . -vv

# Create the Yleaf command-line script
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/Yleaf" << 'EOF'
#!/bin/bash
exec python -m yleaf "$@"
EOF
chmod +x "${PREFIX}/bin/Yleaf"