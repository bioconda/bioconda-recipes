#!/usr/bin/env bash

set -euo pipefail

# configure
meson setup \
	--buildtype=release \
	--prefix="$PREFIX" \
	-Db_ndebug=true \
	builddir

# build
meson compile -C builddir

# install
meson install -C builddir
