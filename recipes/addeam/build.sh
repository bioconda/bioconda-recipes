#!/bin/bash
set -e  # Exit on error

# fix zlib error
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

# Make sure binaries and scripts are installed in Conda's bin directory
mkdir -p "${PREFIX}/bin"

# Move into the source directory and compile C++ binary
cd submodules/src/
make clean
make
mv bam2prof "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/bam2prof"
cd ../..

# Ensure Python scripts are installed correctly
cp addeam-bam2prof.py addeam-cluster.py "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/addeam-bam2prof.py" "${PREFIX}/bin/addeam-cluster.py"

# Add ${PREFIX}/bin to PATH so tests can find the executables
export PATH="${PREFIX}/bin:$PATH"



# #!/bin/bash
# set -e  # Exit immediately if a command exits with a non-zero status

# # Create the bin directory in the Conda environment
# mkdir -p "${PREFIX}/bin"

# # Move into the source directory where the Makefile is located
# cd src

# # Clean previous builds and compile using the passed compiler flags.
# # This mimics the approach in metaDMG-cpp's build.sh.
# make clean
# make

# # Ensure the main binary is executable and install it
# mv bam2prof "${PREFIX}/bin/"
# chmod +x "${PREFIX}/bin/bam2prof"

# # Return to the top-level directory
# cd ..

# # Install the Python scripts into the Conda bin directory
# cp bam2prof.py cluster.py "${PREFIX}/bin/"
# chmod +x "${PREFIX}/bin/bam2prof.py" "${PREFIX}/bin/cluster.py"
