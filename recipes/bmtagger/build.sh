#!/bin/bash
set -x

if [[ $(arch) == aarch64 ]]; then
    sed -i '4a #include <time.h>' general/cprogressindicator.hpp
    sed -i '270s%template%//template%g' general/cgetopt.hpp
    sed -i '40s%std%(bool)std%g' general/cfareader.hpp
    sed -i '46s%std%(bool)std%g' general/cfareader.hpp
    sed -i '10s/\"\\x1b\[\"c/\"\\x1b\[\" c/g' general/of-debug.hpp
    make -C general CXX=${CXX} CC=${CC}
    make -C bmtagger CXX=${CXX} CC=${CC}
    cd bmtagger
fi

install -d ${PREFIX}/bin
install bmfilter ${PREFIX}/bin/
install bmtool ${PREFIX}/bin/
install extract_fullseq ${PREFIX}/bin/
install bmtagger.sh ${PREFIX}/bin/
install bmdump ${PREFIX}/bin/
install bmdiff ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/*

