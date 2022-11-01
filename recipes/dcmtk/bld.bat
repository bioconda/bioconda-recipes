mkdir build
cd build

cmake ^
    -G Ninja ^
    -D CMAKE_BUILD_TYPE:STRING=Release ^
    -D BUILD_SHARED_LIBS:BOOL=TRUE ^
    -D CMAKE_INSTALL_PREFIX=%PREFIX% ^
    -D ENABLE_PRIVATE_TAGS:BOOL=TRUE ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release --target install -j 4
if errorlevel 1 exit 1
