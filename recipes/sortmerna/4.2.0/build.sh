#
# FILE: build.sh
# Created: Dec 08, 2019 Sun
#
# standard Conda build script for building sortmerna v4.2.0
# Uses pre-built binaries from Sortmerna GitHub Releases
#
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"
mv ./bin/sortmerna $PREFIX/bin