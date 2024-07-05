#!/usr/bin/env bash

case $(uname -m) in
    aarch64) 
        HYPHY_OPTS=""
        ;;
    *)
        HYPHY_OPTS="-DNOAVX=ON"
        ;;
esac

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ${HYPHY_OPTS} .
make hyphy HYPHYMPI
make install
