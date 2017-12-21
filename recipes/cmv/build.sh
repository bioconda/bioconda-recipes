#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
if [ `uname` == Darwin ]
then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
    export STACK_ROOT="${SRC_DIR}/s"
    echo "<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleIdentifier</key><string>com.github.eggzilla.cmv</string></dict></plist>" > $SRC_DIR/Info.plist
    stack setup --extra-include-dirs ${PREFIX}/include --extra-lib-dirs [${PREFIX}/lib] --local-bin-path ${SRC_DIR}/s
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
    rm -r "${SRC_DIR}/s"
else
    stack setup
    stack update
    stack install --extra-include-dirs ${PREFIX}/include --extra-lib-dirs ${PREFIX}/lib --local-bin-path ${PREFIX}/bin
fi
#cleanup
rm -r .stack-work

