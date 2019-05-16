#!/bin/bash

HOME=/tmp cpanm HotSpot3D-${PKG_VERSION}.tar.gz
chmod u+rw ${PREFIX}/bin/hotspot3d
