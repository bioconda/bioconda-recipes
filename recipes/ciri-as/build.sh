#!/bin/bash
mkdir -p $PREFIX/bin

# Write the shebang to the file first

echo '#!/usr/bin/env perl' > $PREFIX/bin/CIRI_AS.pl

# Append the original script content right under it

cat download >> $PREFIX/bin/CIRI_AS.pl

# Make it executable

chmod +x $PREFIX/bin/CIRI_AS.pl