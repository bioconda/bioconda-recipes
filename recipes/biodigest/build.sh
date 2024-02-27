#!/usr/bin/env bash

python -m pip install . -vvv --no-deps --no-build-isolation
python -c "
import sysconfig
import os
from biodigest import setup
setup.main(setup_type='api', path=os.path.join(os.getenv('PREFIX'), 'lib', 'python' + sysconfig.get_python_version(), 'site-packages', 'biodigest', 'mapping_files'))
"