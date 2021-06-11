#!/bin/bash
$PYTHON -m pip install git+https://github.com/hmenager/connexion.git@master#egg=connexion[swagger-ui]
$PYTHON -m pip install . --no-deps --ignore-installed -vv
