#!/bin/bash

# Install package into the share directory to allow for unit tests to be run.
SHARE_DIR=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}
mkdir -p ${SHARE_DIR}

# Copy across unit tests and python scripts
cp -r unit-tests ${SHARE_DIR}

# Build the binary
cd source
make clean
make CC=$CXX CFLAGS="$CXXFLAGS"

# Move built binary across to the shared bin and symlink it
mkdir -p ${SHARE_DIR}/bin/
cd ../bin
chmod +x ExpressBetaDiversity
cp ExpressBetaDiversity ${SHARE_DIR}/bin/

# Create the binary
mkdir -p ${PREFIX}/bin/
cat <<EOF >${PREFIX}/bin/ExpressBetaDiversity
#!/bin/bash
cd ${SHARE_DIR}/bin/
./ExpressBetaDiversity "\$@"
EOF
chmod +x ${PREFIX}/bin/ExpressBetaDiversity

# Copy across python scripts
cd ../scripts
cp AbstractPlot.py convertToEBD.py convertToFullMatrix.py pcoaPlot.py ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/AbstractPlot.py
chmod +x ${PREFIX}/bin/convertToEBD.py
chmod +x ${PREFIX}/bin/convertToFullMatrix.py
chmod +x ${PREFIX}/bin/pcoaPlot.py
