@echo off
REM Windows build script for scriptmanager
REM (in case of submission to conda-forge)

set SHARE_DIR=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%
mkdir "%SHARE_DIR%"

REM Install the JAR
copy "%SRC_DIR%\%PKG_NAME%-v%PKG_VERSION%.jar" "%SHARE_DIR%\"
if errorlevel 1 exit /b 1

REM Create the wrapper batch script
mkdir "%PREFIX%\Scripts" 2>nul

(
echo @echo off
echo REM Conda wrapper for %PKG_NAME% %PKG_VERSION%
echo.
echo if not defined JAVA_OPTS set JAVA_OPTS=-Xmx2g
echo.
echo java %%JAVA_OPTS%% -jar "%%CONDA_PREFIX%%\share\%PKG_NAME%-%PKG_VERSION%\%PKG_NAME%-v%PKG_VERSION%.jar" %%*
) > "%PREFIX%\Scripts\%PKG_NAME%.bat"
if errorlevel 1 exit /b 1

exit /b 0
