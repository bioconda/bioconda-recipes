#!/bin/sh

pkg_config_dir=$(find ${PREFIX}/lib -name "bamtools-*.pc" -exec dirname {} \; | tail -n1)
if [ ! -z "${pkg_config_dir}" ]; then
  ./configure --prefix="${PREFIX}" PKG_CONFIG_PATH=${pkg_config_dir}
else
  ./configure --prefix="${PREFIX}"
fi
make
make install
make check
