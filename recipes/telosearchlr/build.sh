#!/bin/bash

mkdir -p ${PREFIX}/bin
for f in *.py;
do
  if ! grep -q "^#!/usr/bin/env python3" "$f"; then
    sed -i "1i #!/usr/bin/env python3" "$f"
  fi
done
chmod +x *.py
mv *.py $PREFIX/bin
