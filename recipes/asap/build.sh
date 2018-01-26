mkdir build

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

export INCLUDE_PATH="${PREFIX}/include/dcmtk/dcmjpeg/"
export CPPFLAGS="-I${PREFIX}/include/dcmtk/dcmjpeg/"


cmake \
    -B ./build \
    -D CMAKE_INSTALL_PREFIX=${PREFIX} \
    -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D BUILD_DIAG_PATHOLOGY_WORKSTATION:BOOL=OFF \
    -D BUILD_DIAG_PATHOLOGY_IMAGEPROCESSING:BOOL=ON \
    -D BUILD_DIAG_PATHOLOGY_EXECUTABLES:BOOL=ON \
    -D OPENSLIDE_LIBRARY:STRING=${PREFIX}/lib \
    -D OPENSLIDE_INCLUDE_DIR:STRING=${PREFIX}/include/openslide \
    -D DCMTKJPEG_LIBRARY:STRING=${PREFIX}/lib \
    -D DCMTKJPEG_INCLUDE_DIR:STRING=${PREFIX}/include \
    .

make -j$CPU_COUNT
make install
