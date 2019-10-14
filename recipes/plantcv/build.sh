#!/bin/bash

find / -name libGL.so.1 -print
sed -i'' -e 's/versioneer.get_version()/"3.3.0"/g' setup.py
sed -i'' -e 's/cmdclass=versioneer.get_cmdclass(),//g' setup.py
sed -i'' -e 's/setup_requires=\["pytest-runner"\],//g' setup.py
sed -i'' -e "s/tests_require=\['pytest'\],//g" setup.py
$PYTHON -m pip install --no-deps --ignore-installed .
