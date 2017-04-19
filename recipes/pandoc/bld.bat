msiexec /a pandoc-%PKG_VERSION%-windows.msi /qb TARGETDIR=%TEMP% || exit 1

if not exist %SCRIPTS% mkdir %SCRIPTS% || exit 1

copy %TEMP%\Pandoc\*.exe %SCRIPTS% || exit 1
