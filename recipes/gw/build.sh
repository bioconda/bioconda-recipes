set -x -e

echo "PATH" $PATH
echo "PREFIX" $PREFIX

ls $PREFIX

make prep
make
mkdir -p $PREFIX/bin
cp gw $PREFIX/bin/gw
chmod u+x $PREFIX/bin/gw
