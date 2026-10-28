#!/bin/bash
# Every TOPP tool links the TOPP tool framework library (libOpenMS_CLI), which
# is its own layer of the installed package since OpenMS 3.6 (see
# cmake/install_macros.cmake in OpenMS: the package is layered core -> CLI ->
# GUI, one pair of install components each). The tools therefore need the
# "library_cli" component on top of the core "library" component that the
# libopenms output installs. CPack knows this as "Applications DEPENDS
# library_cli", but cmake_install.cmake installs exactly the component it is
# handed and honours no component dependencies, so both have to be named here.
# Installing "Applications" alone produces tools that die at startup with
#   OpenMSInfo: error while loading shared libraries: libOpenMS_CLI.so
# The CLI layer belongs to this package and not to libopenms: libopenms is the
# core layer that pyopenms builds against, and it stays free of the
# command-line framework.
#
# Since this package owns the CLI layer, it also ships that layer's development
# files: the headers of the tool framework (OpenMS_CLI_headers, e.g.
# OpenMS/APPLICATIONS/TOPPBase.h) and its exported CMake targets (cmake_cli,
# lib/cmake/OpenMS/OpenMSCLITargets.cmake). OpenMSConfig.cmake from libopenms
# picks the latter up when present, so with this package installed
#   find_package(OpenMS CONFIG REQUIRED COMPONENTS CLI)
# provides OpenMS::OpenMS_CLI and external projects can build their own
# TOPP-style tools against the conda installation.
for component in library_cli OpenMS_CLI_headers cmake_cli Applications; do
  if [[ "$target_platform" == osx-* ]]; then
    # Conda adds the $PREFIX/lib RPATH already in LDFLAGS. We could remove it there before building.
    # For now just ignore the meaningless warning.
    cmake -DCOMPONENT="${component}" -P build/cmake_install.cmake 2>&1 | grep -v "would duplicate path"
  else
    cmake -DCOMPONENT="${component}" -P build/cmake_install.cmake
  fi
done
