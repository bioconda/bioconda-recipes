#!/bin/bash
mkdir -p ${PREFIX}/bin

chmod 777 bactopia
chmod 777 bin/helpers/*.py

mv bactopia ${PREFIX}/bin
mv bin/setup-datasets.py ${PREFIX}/bin/setup-datasets
mv bin/helpers/*.py ${PREFIX}/bin
