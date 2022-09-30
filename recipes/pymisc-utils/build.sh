#!/bin/bash
"${PYTHON}" -m pip install . --ignore-installed --no-deps -vv
install -d "${PREFIX}/bin"
install misc/*.py "${PREFIX}/bin/"
