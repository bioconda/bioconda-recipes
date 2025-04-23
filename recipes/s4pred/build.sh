#!/bin/bash

# Exit on any error
set -ex

# Add shebangs to scripts
sed -i.bak '1s|^|#!/usr/bin/env python\n|' run_model.py
sed -i.bak '1s|^|#!/usr/bin/env python\n|' utilities.py
sed -i.bak '1s|^|#!/usr/bin/env python\n|' network.py

chmod +x run_model.py utilities.py network.py

# Create target directory for code and weights
INSTALL_DIR="${PREFIX}/share/s4pred"
mkdir -p "$INSTALL_DIR"

# Move code to install dir
mv run_model.py "$INSTALL_DIR"
mv utilities.py "$INSTALL_DIR"
mv network.py "$INSTALL_DIR"

# Download and extract weights
wget http://bioinfadmin.cs.ucl.ac.uk/downloads/s4pred/weights.tar.gz
tar -xvzf weights.tar.gz

# Move weights to same location
mv weights "$INSTALL_DIR"

# Create wrapper bash scripts in bin/
mkdir -p "${PREFIX}/bin"

cat <<EOF > "${PREFIX}/bin/run_model"
#!/bin/bash
exec python "${INSTALL_DIR}/run_model.py" "\$@"
EOF

cat <<EOF > "${PREFIX}/bin/utilities"
#!/bin/bash
exec python "${INSTALL_DIR}/utilities.py" "\$@"
EOF

cat <<EOF > "${PREFIX}/bin/network"
#!/bin/bash
exec python "${INSTALL_DIR}/network.py" "\$@"
EOF

chmod +x "${PREFIX}/bin/run_model"
chmod +x "${PREFIX}/bin/utilities"
chmod +x "${PREFIX}/bin/network"

echo "Installation complete."
