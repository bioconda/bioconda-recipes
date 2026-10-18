#!/bin/bash
OS=$(uname -s) #recovering the operating system name
ARCH=$(uname -m)

case "$OS" in
  Linux)
    NeEstimator="Ne2-1L" #name of the executable file NeEstimator for Linux
    if [[ "$ARCH" == "x86_64" ]]; then
        BIN_PATH="inst/bin/linux"
    else
        BIN_PATH="inst/bin/linux32bit"
    fi
    ;;
  CYGWIN*|MINGW*|MSYS*)
    NeEstimator="Ne2-1.exe" #name of the executable file NeEstimator for Windows
    if [[ "$ARCH" == "x86_64" ]]; then
        BIN_PATH="inst/bin/windows64"
    else
        BIN_PATH="inst/bin/windows32bit"
    fi
    ;;
  Darwin)
    NeEstimator="Ne2-1M" #name of the executable file NeEstimator for Mac
    if [[ "$ARCH" == "x86_64" ]] || [[ "$ARCH" == "arm64" ]]; then
        BIN_PATH="inst/bin/Mac"
    else
        BIN_PATH="inst/bin/Mac32bit"
    fi
    ;;
  *)
    echo "OS $OS no support"
    exit 1
    ;;
esac

R CMD INSTALL --build .

mkdir -p $PREFIX/bin
cp "$BIN_PATH/$NeEstimator" $PREFIX/bin/
chmod +x $PREFIX/bin/$NeEstimator