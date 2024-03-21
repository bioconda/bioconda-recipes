#!/bin/bash

${PYTHON} -m pip install . --no-deps --ignore-installed -vv

# Prefix '.py' has been removed from v3.0.5
# symlinking for reverse compatibility, as suggested in release notes
ln -s ${PREFIX}/bin/cpat ${PREFIX}/bin/cpat.py
ln -s ${PREFIX}/bin/make_hexamer_tab ${PREFIX}/bin/make_hexamer_tab.py
ln -s ${PREFIX}/bin/make_logitModel ${PREFIX}/bin/make_logitModel.py
