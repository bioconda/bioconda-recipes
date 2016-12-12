#!/bin/bash

# Fix other pins to accept more recent versions
sed -i.bak 's/psutil==/psutil>=/' setup.py
sed -i.bak 's/boto==/boto>=/' setup.py
sed -i.bak 's/azure==/azure>=/' setup.py
sed -i.bak 's/pynacl==/pynacl>=/' setup.py
sed -i.bak 's/cwltool==/cwltool>=/' setup.py
sed -i.bak 's/gcs_oauth2_boto_plugin==/gcs_oauth2_boto_plugin>=/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
