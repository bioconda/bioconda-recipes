#!/usr/bin/env bash

"${PYTHON}" -m pip install --no-deps --ignore-installed *.whl

# Add link to PATH for testing.
RFPLASMIDPATH=`python3 -c "import RFPlasmid as _; print(_.__path__)"|sed 's/^\[.//' |sed 's/.\]$//'`
chmod 755 ${RFPLASMIDPATH}/rfplasmid.py
ln -s ${RFPLASMIDPATH}/rfplasmid.py ${PREFIX}/bin
