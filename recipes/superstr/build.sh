#!/bin/sh
cd C
cmake .
make
cp superstr $PREFIX/bin/superstr
cd ../Python
cp multiparse.py $PREFIX/bin/superstr-multiparse.py
echo '#!/usr/bin/env python' > $PREFIX/bin/superstr-outliers.py
cat outliers.py >> $PREFIX/bin/superstr-outliers.py
cp screen.py $PREFIX/bin/superstr-screen.py
cp visualise.py $PREFIX/bin/superstr-visualise.py
chmod +x $PREFIX/bin/superstr-multiparse.py
chmod +x $PREFIX/bin/superstr-outliers.py
chmod +x $PREFIX/bin/superstr-screen.py
chmod +x $PREFIX/bin/superstr-visualise.py
