!/bin/bash

cd nni
pip install --upgrade setuptools pip wheel

export NNI_RELEASE=2.0
python setup.py build_ts
python setup.py bdist_wheel