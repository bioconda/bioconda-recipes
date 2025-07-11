#!/bin/bash
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
mkdir -p ~/.R


echo -e "CC=$CC
FC=$FC
CXX=$CXX
CXX98=$CXX
CXX11=$CXX
CXX14=$CXX" > ~/.R/Makevars

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
  export MACOSX_SDK_VERSION=10.15
  export CFLAGS="${CFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY -fno-define-target-os-macros"
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

$R CMD INSTALL --build .
