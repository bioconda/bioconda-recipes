#$PYTHON setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.
R CMD INSTALL -l Rlib dependencies/BMS_0.3.3.tar.gz
$PYTHON setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.