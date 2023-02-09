@echo off
(echo @echo off & echo python -m %PKG_NAME% %%*) > %CONDA_PREFIX%\Scripts\%PKG_NAME%.bat

