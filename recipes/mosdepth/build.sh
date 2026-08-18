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
D4_LIB_DIR="$(pwd)/d4-format/target/release"
D4_INCLUDE_DIR="$(pwd)/d4-format/d4binding/include"
# Cargo emits a shared library (libd4binding.so/.dylib) alongside the static one; removing it
# forces the linker to pick up the static .a instead, since both gcc and clang prefer a
# dynamic library over a static one of the same name when both are on the search path.
rm -f "${D4_LIB_DIR}"/libd4binding.so "${D4_LIB_DIR}"/libd4binding.dylib
export LIBRARY_PATH="${D4_LIB_DIR}:${LIBRARY_PATH:-}"
export C_INCLUDE_PATH="${D4_INCLUDE_DIR}:${C_INCLUDE_PATH:-}"

if [[ "$(uname -m)" == "arm64" ]]; then
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
# it), so `nimble build` fails to find it. Fetching dependencies and invoking nim directly with
# --nimblePath instead of nimble's generated --path list resolves packages the same way nim's
# own global nimble integration does, and isn't tripped up by d4-nim's layout.
nimble --localdeps install -y --verbose --depsOnly
nim c -d:d4 -d:release --mm:refc --nimblePath:nimbledeps/pkgs2 -o:mosdepth mosdepth.nim

install -v -m 0755 mosdepth "${PREFIX}/bin"
