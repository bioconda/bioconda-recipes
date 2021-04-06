#!/bin/sh
TARGET=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

cd "$TARGET/"
perl autoInstall.pl -condaDBinstall
