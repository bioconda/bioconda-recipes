#!/bin/sh

echo '#!/bin/bash' > test-glibc.sh
ldd --version | xargs -i{} echo "echo '{}'" >> test-glibc.sh
chmod +x test-glibc.sh

cat test-glibc.sh
mkdir -p $PREFIX/bin/
cp test-glibc.sh $PREFIX/bin/

