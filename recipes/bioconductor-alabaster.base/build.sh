#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R

# Handle MacOSX
if [ $(uname) == 'Darwin' ];
then
  if [[ $(uname -m) == 'x86_64' ]]; then
    SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
    echo "-isysroot is ${SDKROOT}"
    export CFLAGS="${CFLAGS} -isysroot ${SDKROOT}"
    export LDFLAGS="${LDFLAGS} -isysroot ${SDKROOT}"
  fi
  export MACOSX_DEPLOYMENT_TARGET=10.15
  export OSX_DEPLOYMENT_TARGET=10.15=10.15
  export MACOSX_SDK_VERSION=10.15
  export CFLAGS="${CFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -fno-define-target-os-macros  -mmacosx-version-min=10.15"
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15  -mmacosx-version-min=10.15"
   
fi

# I don't think this is right because it's for compiling R packages
echo -e "CC=$CC
CFLAGS=$CFLAGS
LDFLAGS=$LDFLAGS
FC=$FC
CXX=$CXX
CXXFLAGS=$CXXFLAGS
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

$R CMD INSTALL --build .
