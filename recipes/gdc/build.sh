#! /bin/bash

cd gdc_2/Gdc2/
if [[ ${target_platform} =~ linux.* ]]; then
    makefile=makefile.linux
elif [[ ${target_platform} =~ osx.* ]]; then
    makefile=makefile.mac
else
    echo "operating system not found or not supported"
    exit 1
fi
# Object files/libraries in wrong order => can't use --as-needed.
# (and clange does not seem to support --no-as-needed).
export LDFLAGS="${LDFLAGS//-Wl,--as-needed/}"
make \
    -f "${makefile}" \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}"
install -d "${PREFIX}/bin"
install gdc2 "${PREFIX}/bin/"
