cd w%ARCH%
copy config_VC config.h

nmake /f Makefile_VC

mkdir %PREFIX%\bin
mkdir %PREFIX%\include
mkdir %PREFIX%\libs

copy glpsol.exe %PREFIX%\bin
copy ..\src\glpk.h %PREFIX%\include
copy glpk.lib %PREFIX%\libs

if errorlevel 1 exit 1
