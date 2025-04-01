@echo off
mkdir "%PREFIX%\Library\bin\clincnv"
xcopy /s /e /y "%SRC_DIR%\*" "%PREFIX%\Library\bin\clincnv\"

for %%s in (clinCNV.R mergeFilesFromFolder.R mergeFilesFromFolderDT.R) do (
    echo @echo off > "%PREFIX%\Scripts\%%s.bat"
    echo Rscript "%CONDA_PREFIX%\Library\bin\clincnv\%%s" %%* >> "%PREFIX%\Scripts\%%s.bat"
)