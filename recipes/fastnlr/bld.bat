@echo on
setlocal EnableDelayedExpansion

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 exit 1

cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path crates\nlr-cli
if errorlevel 1 exit 1

if not exist "%LIBRARY_PREFIX%\licenses" mkdir "%LIBRARY_PREFIX%\licenses"
copy /Y "%SRC_DIR%\THIRDPARTY.yml" "%LIBRARY_PREFIX%\licenses\THIRDPARTY.yml"
if errorlevel 1 exit 1
