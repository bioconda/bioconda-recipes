#!/usr/bin/env bash

set -euo pipefail

# configure
meson setup \
	--buildtype=release \
	--default-library=static \
	--wrap-mode=forcefallback \
	--prefix="$PREFIX" \
	-Db_ndebug=true \
	builddir

# build
meson compile -C builddir

# install
meson install -C builddir
