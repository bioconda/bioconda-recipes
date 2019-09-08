#!/bin/bash

# Fix other pins to accept more recent versions
sed -i.bak 's/azure==/azure>=/' setup.py
sed -i.bak 's/boto==/boto>=/' setup.py
sed -i.bak 's/cwltool==/cwltool>=/' setup.py
sed -i.bak 's/dill==/dill>=/' setup.py
sed -i.bak 's/gcs_oauth2_boto_plugin==/gcs_oauth2_boto_plugin>=/' setup.py
sed -i.bak 's/psutil==/psutil>=/' setup.py
sed -i.bak 's/pynacl==/pynacl>=/' setup.py
sed -i.bak 's/docker==/docker>=/' setup.py
sed -i.bak 's/galaxy-lib==/galaxy-lib>=/' setup.py
sed -i.bak 's/requests==/requests>=/' setup.py
sed -i.bak 's/pathlib2==/pathlib2>=/' setup.py

# For non-releases only: Avoid needing git/.git for version prep
#sed -i.bak 's/return _version()/return distVersion()/' version_template.py
#sed -i.bak 's/return _version(shorten=True)/return distVersion()/' version_template.py
#sed -i.bak 's/def currentCommit()/def _currentCommit()/' version_template.py
#sed -i.bak 's/def dirty()/def _dirty()/' version_template.py

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
