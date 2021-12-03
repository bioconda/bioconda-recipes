#!/usr/bin/env bash
set -e
set -x

platform="$(uname)"
unzip comet_source_"$PKG_VERSION".zip
if [ "$platform" = "Darwin" ]; then
    sed -i.bak -e 's/ -static//' -e 's/ -o / -headerpad_max_install_names&/' Makefile
    sed -i.bak -e "s/sha1Report='..'/sha1Report=NULL/" MSToolkit/include/MSReader.h
    sed -i.bak "s/ off64_t / off_t /g" CometSearch/Common.h
    sed -i.bak "s/fseeko64/fseeko/g;s/ftello64/ftello/g" MSToolkit/include/mzParser.h
    sed -i.bak "s/fseeko64/fseeko/g;s/ftello64/ftello/g" CometSearch/Common.h
    sed -i.bak "s/pthread_yield/sched_yield/g;" CometSearch/ThreadPool.h
fi
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" CometSearch/Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" MSToolkit/Makefile
make CXX=${CXX}
mkdir -p "$PREFIX"/bin
cp comet.exe ${PREFIX}/bin/comet
chmod a+x ${PREFIX}/bin/comet
cd "$PREFIX"/bin/
ln -s comet comet.exe
