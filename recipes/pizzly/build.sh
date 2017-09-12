#!/bin/sh
cp pizzly $PREFIX/bin
blob=251989979ba2cb39e217a91aa7fefc85c554ebe1
wget https://raw.githubusercontent.com/pmelsted/pizzly/${blob}/scripts/flatten_json.py -O $PREFIX/bin/pizzly_flatten_json.py
sed -i.bak '1 i\
#!/usr/bin/env python -Es' $PREFIX/bin/pizzly_flatten_json.py
chmod +x $PREFIX/bin/pizzly_flatten_json.py

wget https://raw.githubusercontent.com/pmelsted/pizzly/${blob}/scripts/get_fragment_length.py -O $PREFIX/bin/pizzly_get_fragment_length.py
chmod +x $PREFIX/bin/pizzly_get_fragment_length.py
sed -i.bak '1 i\
#!/usr/bin/env python -Es' $PREFIX/bin/pizzly_get_fragment_length.py
