@echo on

REM Build script for conda on Windows

REM Configure and build with CMake via scikit-build-core
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

REM Verify the installation
%PYTHON% -c "import zna; print('ZNA installed successfully')"
if errorlevel 1 exit 1

%PYTHON% -c "from zna.core import is_accelerated; print(f'C++ acceleration: {is_accelerated()}')"
if errorlevel 1 exit 1
