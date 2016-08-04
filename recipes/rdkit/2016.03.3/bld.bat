%PYTHON% "%RECIPE_DIR%\fetch_inchi.py"
%PYTHON% "%RECIPE_DIR%\fetch_avalontools.py"

cmake ^
    -G "NMake Makefiles" ^
    -D RDK_INSTALL_INTREE=OFF ^
    -D RDK_BUILD_INCHI_SUPPORT=ON ^
    -D RDK_BUILD_AVALON_SUPPORT=ON ^
    -D RDK_USE_FLEXBISON=OFF ^
    -D AVALONTOOLS_DIR="%SRC_DIR%\External\AvalonTools\src\SourceDistribution" ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR="%PREFIX%\include" ^
    -D PYTHON_LIBRARY="%PREFIX%\libs\python27.lib" ^
    -D PYTHON_INSTDIR="%SP_DIR%" ^
    -D BOOST_ROOT="%LIBRARY_PREFIX%" -D Boost_NO_SYSTEM_PATHS=ON ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    .

rem set

nmake

rem extend the environment settings in preparation to tests
set RDBASE=%SRC_DIR%
set PYTHONPATH=%RDBASE%

nmake test

nmake install

