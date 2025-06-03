#!/bin/bash -euo

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
LDFLAGS=""
export LDLIBS="-L${PREFIX}/lib -lz -lzstd -pthread"

# Fetch third party dependencies
# (Git submodules - https://github.com/BenLangmead/bowtie2/blob/a43fa6f43f54989468a294967898f85b9fe4cefa/.gitmodules)
git clone --branch master https://github.com/simd-everywhere/simde-no-tests.git third_party/simde
git clone https://github.com/ch4rr0/libsais third_party/libsais

sed -i.bak 's|VERSION 3.1 FATAL_ERROR|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DAPPLE=ON -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DUSE_SRA=ON -DUSE_SAIS=ON -Wno-dev -Wno-deprecated \
	--no-warn-unused-cli "${CONFIG_ARGS}"
cmake --build build --clean-first --target install -j "${CPU_COUNT}"

#binaries="\
#bowtie2 \
#bowtie2-align-l \
#bowtie2-align-s \
#bowtie2-build \
#bowtie2-build-l \
#bowtie2-build-s \
#bowtie2-inspect \
#bowtie2-inspect-l \
#bowtie2-inspect-s \
#"
#directories="scripts"

#for i in ${binaries}; do
#    install -v -m 0755 ${i} "${PREFIX}/bin"
#done

#for d in ${directories}; do
#    cp -rf ${d} "${PREFIX}/bin"
#done

#cd build && make clean
