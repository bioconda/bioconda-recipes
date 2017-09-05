#!/bin/sh
cp pizzly $PREFIX/bin
wget https://raw.githubusercontent.com/pmelsted/pizzly/master/scripts/flatten_json.py -O $PREFIX/bin/pizzly_flatten_json.py
sed -i.bak "1s@^@#!/usr/bin/env python\'$'\n@g" $PREFIX/bin/pizzly_flatten_json.py
chmod +x $PREFIX/bin/pizzly_flatten_json.py
wget https://raw.githubusercontent.com/pmelsted/pizzly/master/scripts/get_fragment_length.py -O $PREFIX/bin/pizzly_get_fragment_length.py
sed -i.bak "1s@^@#!/usr/bin/env python\'$'\n@g" $PREFIX/bin/pizzly_get_fragment_length.py
chmod +x $PREFIX/bin/pizzly_get_fragment_length.py
