#!/bin/bash

sed -i 's/install_requires=requires,/#/g' setup.py
${PYTHON} setup.py install
