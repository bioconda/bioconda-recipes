#!/bin/bash

# Fix cwltool pin to be compatible with arvados-cwl-runner
sed -i.bak 's/cwltool==1.0.20160425140546/cwltool==1.0.20160427142240/' setup.py
# Fix other pins to accept more recent versions
sed -i.bak 's/psutil==/psutil>=/' setup.py
sed -i.bak 's/boto==/boto>=/' setup.py
sed -i.bak 's/azure==/azure>=/' setup.py
sed -i.bak 's/pynacl==/pynacl>=/' setup.py
sed -i.bak 's/gcs_oauth2_boto_plugin==/gcs_oauth2_boto_plugin>=/' setup.py
$PYTHON setup.py install --single-version-externally-managed --record=record.txt
