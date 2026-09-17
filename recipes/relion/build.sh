#!/bin/bash
set -xe

mkdir -p "${PREFIX}/share/.cache/torch"
OS=$(uname -s)
ARCH=$(uname -m)

export CXXFLAGS="${CXXFLAGS} -O3 -Wno-deprecated-declarations"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

case "${ARCH}" in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    #x86_64)
	#export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	#;;
esac

sed -i.bak -E \
  -e 's/target_link_libraries\(\$\{_target\} relion_lib/target_link_libraries(${_target} PUBLIC relion_lib/' \
  -e 's/target_link_libraries\(\$\{_target\} \$\{TIFF_LIBRARIES\}/target_link_libraries(${_target} PUBLIC ${TIFF_LIBRARIES}/' \
  -e 's/target_link_libraries\(\$\{_target\} sycl OpenCL relion_lib/target_link_libraries(${_target} PUBLIC sycl OpenCL relion_lib/' \
  -e 's/target_link_libraries\(\$\{_target\} \$\{TBB_LIBRARIES\}/target_link_libraries(${_target} PUBLIC ${TBB_LIBRARIES}/' \
  -e 's/target_link_libraries\(relion_lib \$\{OpenMP_omp_LIBRARY\}/target_link_libraries(relion_lib PUBLIC ${OpenMP_omp_LIBRARY}/' \
  src/apps/CMakeLists.txt
rm -f src/apps/*.bak

CMAKE_ARGS=(
	-DCMAKE_BUILD_TYPE=Release -DGUI=OFF -DCUDA=OFF -DFETCH_WEIGHTS=OFF
	-DCMAKE_INSTALL_PREFIX="${PREFIX}"
	-DCMAKE_CXX_COMPILER="${CXX}"
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
	-DTORCH_HOME_PATH="${PREFIX}/share/.cache/torch"
	-DPYTHON_EXE_PATH="$(command -v python3)"
	-Wno-dev -Wno-deprecated --no-warn-unused-cli
)

if [[ "${OS}" == "Darwin" ]]; then
	CMAKE_ARGS+=(
		-DCMAKE_FIND_FRAMEWORK=NEVER
		-DCMAKE_FIND_APPBUNDLE=NEVER
	)
fi

if [[ "${ARCH}" == "x86_64" ]]; then
	CMAKE_ARGS+=(
		-DALTCPU=ON
	)
fi

cmake -S . -B build "${CMAKE_ARGS[@]}"
cmake --build build --target install -j "${CPU_COUNT}"
