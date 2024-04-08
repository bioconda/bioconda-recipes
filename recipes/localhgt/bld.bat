@echo off

REM Run the make command
make

REM Create the bin directory if it doesn't exist
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

REM Copy the Python files
copy "%SRC_DIR%\*py" "%PREFIX%\bin"

REM Copy the shell scripts
copy "%SRC_DIR%\*sh" "%PREFIX%\bin"

REM Copy the 'extract_ref' file
copy "%SRC_DIR%\extract_ref" "%PREFIX%\bin"
