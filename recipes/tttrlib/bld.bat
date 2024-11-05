cd %SRC_DIR%
git submodule update --recursive --init --remote

echo "Build app wrapper"
:: build app wrapper
copy "%RECIPE_DIR%\app_wrapper.c" .
cl app_wrapper.c shell32.lib
if errorlevel 1 exit 1

rmdir b2 /s /q
mkdir b2
cd b2
for /f %%A in ('python -c "import platform; print(platform.python_version())"') do set python_version=%%A
echo Python version: %python_version%
cmake .. -G "NMake Makefiles" ^
 -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
 -DCMAKE_PREFIX_PATH="%PREFIX%" ^
 -DBUILD_PYTHON_INTERFACE=ON ^
 -DCMAKE_BUILD_TYPE=Release ^
 -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="%SP_DIR%" ^
 -DCMAKE_SWIG_OUTDIR="%SP_DIR%" ^
 -DPYTHON_VERSION="%python_version%" ^
 -DBUILD_LIBRARY=ON
nmake install


:: Add wrappers to path for each Python command line tool
:: (all files without an extension)
cd %SRC_DIR%\bin
for /f %%f in ('dir /b *.py') do copy "%SRC_DIR%\bin\%%f" "%PREFIX%\Library\bin\%%f"
for /f %%f in ('dir /b *.') do copy "%SRC_DIR%\app_wrapper.exe" "%PREFIX%\Library\bin\%%f.exe"
if errorlevel 1 exit 1
