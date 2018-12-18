mkdir %PREFIX%/Colombo
if errorlevel 1 exit 1
xcopy /E . %PREFIX%/Colombo
if errorlevel 1 exit 1
ln -s %PREFIX%/Colombo/Colombo/SigiHMM.bat