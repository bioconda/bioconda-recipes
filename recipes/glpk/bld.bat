cd w%ARCH%
copy config_VC config.h

nmake /f Makefile_VC

copy glpsol.exe %LIBRARY_BIN%
copy ..\src\glpk.h %LIBRARY_INC%
copy glpk.lib %LIBRARY_LIB%

if errorlevel 1 exit 1