#!/bin/bash

BUILD_DIR="${SRC_DIR}/build"

export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export CXXFLAGS="${CXXFLAGS} -fPIC -w"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# TODO: mz5 support is nearly working but needs a few fixes in linking certain
# targets
#export HDF5_SUPPORT = 1
#export MZ5_SUPPORT  = 1

echo "INSTALL_DIR  = ${PREFIX}"      >  site.mk
echo "TPP_BASEURL  = /tpp"           >> site.mk
echo "TPP_DATADIR  = ${PREFIX}/data" >> site.mk

# install the dependencies

#cpanm FindBin::libs

make --silent extern

# we don't want/need these extra binaries, especially since some may conflict
# with those provided by other conda packages
rm -rf $BUILD_DIR/bin/*

# These are the actual TPP targets that we want (we skip the Search target
# because those search engines are packaged separately in conda)
make --silent Quantitation
make --silent Validation
make --silent Visualization
make --silent Parsers
make --silent Util
make --silent spectrast
make --silent perl
make --silent mayu

# Move everything to the final destination. This is done instead of 'make
# install' because that command will try to build everything that we've
# intentionally skipped

# NOTE: the files copied from $BUILD_DIR/html and $BUILD_DIR/cgi-bin are
# needed by parts of TPP

mkdir -p $PREFIX/html
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/cgi-bin

chmod +x $BUILD_DIR/bin/*.pl

cp -R $BUILD_DIR/bin          $PREFIX
cp -R $BUILD_DIR/conf         $PREFIX
cp -R $BUILD_DIR/lic          $PREFIX
cp -R $BUILD_DIR/html/PepXML* $PREFIX/html
cp -R $BUILD_DIR/lib/perl/*   $PREFIX/lib

# Generally we don't want the CGI stuff, but these files are specifically
# wanted by GalaxyP
chmod +x $BUILD_DIR/cgi-bin/PepXMLViewer.cgi
chmod +x $BUILD_DIR/cgi-bin/protxml2html.pl
cp -R $BUILD_DIR/cgi-bin/PepXMLViewer.cgi $PREFIX/bin
cp -R $BUILD_DIR/cgi-bin/PepXMLViewer.cgi $PREFIX/cgi-bin
cp -R $BUILD_DIR/cgi-bin/protxml2html.pl  $PREFIX/bin

#----------------------------------------------------------------------------#
# END SCRIPT
#----------------------------------------------------------------------------#

# The following are miscellaneous notes on the process of getting TPP to build
# in the conda system (which was not straightward), for use by future
# packagers/maintainers.
#
# ### Static builds
#
# A few of the TPP programs ask for static compilation, but the static libs of
# various core dependencies (libc, etc) don't seem to be present on the conda
# build system or in any of its packages. As a result, I had to remove the
# '-static' flag in a few places in the Makefiles to get the build working.
#
# ### Silent makes
#
# Most, if not all, of the calls to `make` were patched to include the
# `--silent` flag to cut down on otherwise copious output during the build.
#
# ### Windows-specific components
#
# Since bioconda does not officially support Windows builds, various
# Windows-specific targets were removed.
#
# ### Avoiding conflicts with other conda packages
#
# The TPP distribution includes a number of programs which are also available
# within conda, including hardklor, msconvert, X!Tandem, etc. A number of
# patches were applied to avoid installing these binaries from the TPP package
# so that users don't inadvertently have their conda-managed versions
# overwritten.
