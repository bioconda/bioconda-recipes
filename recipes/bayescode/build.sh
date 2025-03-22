#!/bin/bash
rm -rf data/
# Build specifying CPP compiler and C compiler
# Use sed to replace 'make' with 'make CXX=${CXX} CC=${CC}'
# This is necessary because the Makefile does not respect the CXX and CC variables
# Create bin directory
mkdir bin
mkdir -p "${PREFIX}"/bin/
mv utils/*.py "${PREFIX}"/bin/

# Generate Makefile
cd bin; cmake -DTINY=ON ..

# Build executables mutselomega and readmutselomega
make CXX=${GXX} CC=${CC} -j ${CPU_COUNT} mutselomega readmutselomega
mv mutselomega "${PREFIX}"/bin/; mv readmutselomega "${PREFIX}"/bin/

# Build executables nodemutsel and readnodemutsel
make CXX=${GXX} CC=${CC} -j ${CPU_COUNT} nodemutsel readnodemutsel
mv nodemutsel "${PREFIX}"/bin/; mv readnodemutsel "${PREFIX}"/bin/

# Build executables nodeomega and readnodeomega
make CXX=${GXX} CC=${CC} -j ${CPU_COUNT} nodeomega readnodeomega
mv nodeomega "${PREFIX}"/bin/; mv readnodeomega "${PREFIX}"/bin/

# Build executables nodetraits and readnodetraits
make CXX=${GXX} CC=${CC} -j ${CPU_COUNT} nodetraits readnodetraits
mv nodetraits "${PREFIX}"/bin/; mv readnodetraits "${PREFIX}"/bin/