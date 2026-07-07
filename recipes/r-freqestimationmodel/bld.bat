"%R%" CMD INSTALL --build . --no-build-vignettes %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
