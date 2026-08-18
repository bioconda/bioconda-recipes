#!/bin/bash
set -x

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-lpthread|-pthread|' nim.cfg
rm -rf *.bak

# Build d4binding (the C API for 38/d4-format), statically, so mosdepth's --d4 output support
# adds no new runtime dependency on top of what mosdepth already needs.
pushd d4-format
cargo build --release --package=d4binding
popd
# Not d4-format/target/release: conda-forge's rust_<platform> activation sets
# CARGO_BUILD_TARGET to an explicit target triple even for a "native" build (observed on
# osx-arm64), which makes cargo place output under target/<triple>/release/ instead. Locating
# the actual output on disk works regardless of whether a target triple is in play.
D4_LIB_DIR="$(dirname "$(find "$(pwd)/d4-format/target" -name 'libd4binding.a' -not -path '*/deps/*' -print -quit)")"
D4_INCLUDE_DIR="$(pwd)/d4-format/d4binding/include"
# Cargo emits a shared library (libd4binding.so/.dylib) alongside the static one; removing it
# forces the linker to pick up the static .a instead, since both gcc and clang prefer a
# dynamic library over a static one of the same name when both are on the search path.
rm -f "${D4_LIB_DIR}"/libd4binding.so "${D4_LIB_DIR}"/libd4binding.dylib

# d4binding pulls in reqwest (for d4::ssio::http -- d4binding/src/stream.rs uses
# HttpReader unconditionally, so the "http_reader" feature can't be dropped the way
# "depth_profiler" was), which on macOS needs CoreFoundation/SystemConfiguration for its TLS
# and network-reachability code. cargo normally links those frameworks in automatically for
# its own binaries, but not here, since libd4binding.a is only getting linked into mosdepth
# afterwards by nim/clang, well outside cargo's own build.
extra_link_flags=()
if [[ "$(uname -m)" == "arm64" ]]; then
	extra_link_flags+=(--passL:"-framework CoreFoundation" --passL:"-framework Security" --passL:"-framework SystemConfiguration")

	nim_build="macosx_arm64"
	curl -SL https://github.com/nim-lang/nightlies/releases/download/latest-version-2-2/${nim_build}.tar.xz -o ${nim_build}.tar.xz
	unxz -c ${nim_build}.tar.xz | tar -x

	cd nim-2.2.*
	export PATH="${PWD}/bin:${PATH}"
	cd ..

	echo "gcc.exe = \"${CC}\"" >> nim-2.2.*/config/nim.cfg
	echo "gcc.linkerexe =\"${CC}\"" >>  nim-2.2.*/config/nim.cfg
	echo "gcc.options.linker %= \"\${gcc.options.linker} ${LDFLAGS}\"" >>  nim-2.2.*/config/nim.cfg
	cat nim-2.2.*/config/nim.cfg
fi

# `nimble build` (used here previously) generates a --path for each dependency assuming it
# keeps its sources under src/. d4-nim doesn't (its own nimble metadata already warns about
# this: the actual d4.nim lives at the package root, with a "d4pkg" subdirectory alongside
# it), so `nimble build` fails to find it.
#
# Fetching dependencies and invoking nim directly instead avoids that specific bug, but a
# single --nimblePath:nimbledeps/pkgs2 isn't a reliable replacement: whether `nimble install`
# leaves a package's sources nested under its own src/ or flattens src/'s contents into the
# package root turns out to depend on the nimble version (observed both ways across the
# nim/nimble versions this recipe builds with across platforms), and --nimblePath doesn't
# handle both layouts uniformly. Resolving each installed package's actual root explicitly,
# by checking which layout it actually got on disk this run, works regardless of that.
nimble --localdeps install -y --verbose --depsOnly
nim_paths=()
for pkg_dir in nimbledeps/pkgs2/*/; do
	if [ -d "${pkg_dir}src" ]; then
		nim_paths+=("--path:${pkg_dir}src")
	else
		nim_paths+=("--path:${pkg_dir}")
	fi
done
# LIBRARY_PATH/C_INCLUDE_PATH aren't reliable here (observed nim's own invocation of the C
# compiler not picking up LIBRARY_PATH for -ld4binding in CI, even though it's exported before
# nim runs and works locally outside this sandbox) -- passing -L/-I straight through nim's own
# --passL/--passC makes it end up on the actual compiler command line no matter what.
nim c -d:d4 -d:release --mm:refc "${nim_paths[@]}" \
	--passL:"-L${D4_LIB_DIR}" --passC:"-I${D4_INCLUDE_DIR}" "${extra_link_flags[@]}" \
	-o:mosdepth mosdepth.nim

install -v -m 0755 mosdepth "${PREFIX}/bin"
