echo off
git submodule update --recursive --init --remote

:: echo "Patch IMPConfig.cmake"
set IMP_CMAKE="%LIBRARY_LIB%\cmake\IMP\IMPConfig.cmake"
powershell -Command "(gc %IMP_CMAKE%) -replace '.dll', '.lib' | Out-File -encoding ASCII %IMP_CMAKE%"

echo "Build documentation.i"
cd doc
mkdir _build\html\stable\api
doxygen
python ../tools/doxy2swig.py _build/xml/index.xml ../pyext/documentation.i
cd ..

echo "Build app wrapper"

:: build app wrapper
copy "%RECIPE_DIR%\app_wrapper.c" .
cl app_wrapper.c shell32.lib
if errorlevel 1 exit 1

mkdir build
cd build

echo on
cmake -G Ninja .. ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%PREFIX:\=/%;%PREFIX:\=/%\Library" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	  -DCMAKE_INSTALL_LIBDIR=bin ^
      -DCMAKE_INSTALL_PYTHONDIR="%SP_DIR%" ^
      -DCMAKE_CXX_FLAGS="/DBOOST_ALL_DYN_LINK /EHsc /DWIN32 /DMSMPI_NO_DEPRECATE_20 /bigobj /DBOOST_ZLIB_BINARY=kernel32"

if errorlevel 1 exit 1

:: Occasionally builds fail on Windows on conda-forge's build hosts
:: due to the compiler running out of heap space. If this happens, try
:: the build again; if it still fails, restrict to one core.
ninja install -k 0
if errorlevel 1 ninja install -k 0
if errorlevel 1 ninja install -k 0 -j 1
if errorlevel 1 exit 1

:: Add wrappers to path for each Python command line tool
:: (all files without an extension)
cd %PREFIX%\Library\bin
for /f %%f in ('dir /b *.') do copy "%SRC_DIR%\app_wrapper.exe" "%PREFIX%\Library\bin\%%f.exe"
if errorlevel 1 exit 1

:: echo "Copy examples"
mkdir -p %PREFIX%\Library\share\doc\IMP\examples\bff
xcopy /e /k /h /i %SRC_DIR%\examples %PREFIX%\Library\share\doc\IMP\examples\bff
:: if errorlevel 1 exit 1
