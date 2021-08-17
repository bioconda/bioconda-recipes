#! /bin/bash
TITAN="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p $PREFIX/bin ${TITAN}

chmod 755 bin/*
cp -f bin/* $PREFIX/bin/

mv conf/ tasks/ workflows/ ${TITAN}
