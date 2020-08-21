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
make \
    -f "${makefile}" \
    CC="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS} -Wl,--no-as-needed"
install -d "${PREFIX}/bin"
install gdc2 "${PREFIX}/bin/"
