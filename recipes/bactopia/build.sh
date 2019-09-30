#!/bin/bash
mkdir -p ${PREFIX}/bin

chmod 777 bactopia
chmod 777 bin/setup-datasets.py
chmod 777 bin/prepare-fofn.py

mv bactopia ${PREFIX}/bin
mv bin/setup-datasets.py ${PREFIX}/bin/setup-datasets
mv bin/prepare-fofn.py ${PREFIX}/bin/prepare-fofn
