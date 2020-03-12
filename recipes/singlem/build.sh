#!/bin/bash

# install python libraries
python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv

# copy main singlem python script
chmod +x bin/singlem
cp bin/singlem ${PREFIX}/bin/
