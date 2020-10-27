
cmake -G"NMake Makefiles" ^
  -DBUILD_SHARED_LIBS:BOOL=ON ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  "%SRC_DIR%"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1
