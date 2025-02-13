# -*- coding: utf-8 -*-
@echo off
REM Ensure target directories exist
if not exist "%PREFIX%\sra-toolkit" mkdir "%PREFIX%\sra-toolkit"
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"

REM Copy all files from the extracted archive to the target directory.
xcopy /E /I /Y * "%PREFIX%\sra-toolkit"

REM Copy executable files from the 'bin' subdirectory to %PREFIX%\Scripts.
for %%F in ("%PREFIX%\sra-toolkit\bin\*") do (
    REM Optionally, check for executability here.
    copy "%%F" "%PREFIX%\Scripts\"
)