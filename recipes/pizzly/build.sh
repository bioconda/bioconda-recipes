#!/bin/sh
cp pizzly $PREFIX/bin
wget https://raw.githubusercontent.com/pmelsted/pizzly/master/scripts/flatten_json.py -O $PREFIX/bin/pizzly_flatten_json.py
chmod +x $PREFIX/bin/pizzly_flatten_json.py
wget https://github.com/pmelsted/pizzly/blob/master/scripts/get_fragment_length.py -O $PREFIX/bin/pizzly_get_fragment_length.py
chmod +x $PREFIX/bin/pizzly_flatten_json.py
