@echo off
"%PYTHON%" -m pip install . --no-deps --ignore-installed -vv
if errorlevel 1 exit 1
