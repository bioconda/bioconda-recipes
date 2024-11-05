mkdir b2 && cd b2

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake \
 -DCMAKE_INSTALL_PREFIX="$PREFIX" \
 -DCMAKE_PREFIX_PATH="$PREFIX" \
 -DBUILD_PYTHON_INTERFACE=ON \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$SP_DIR" \
 -DCMAKE_SWIG_OUTDIR="$SP_DIR" \
 -DBUILD_LIBRARY=ON \
 -DPYTHON_VERSION=$(python -c 'import platform; print(platform.python_version())')\
 -G Ninja ..

# On some platforms (notably aarch64 with Drone) builds can fail due to
# running out of memory. If this happens, try the build again; if it
# still fails, restrict to one core.
ninja install -k 0 || ninja install -k 0 || ninja install -j 1

# Copy programs to bin
cd $PREFIX/bin
cp $SRC_DIR/bin/* .