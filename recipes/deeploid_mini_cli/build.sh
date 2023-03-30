set -e

echo "Building deeploid_mini_cli..."

cp -r $SRC_DIR/* $PREFIX/

mkdir $PREFIX/bin
cd $PREFIX/bin
ln -s $PREFIX/deeploid_mini_cli.py ./deeploid_mini_cli
chmod +x ./deeploid_mini_cli 
$PYTHON ./deeploid_mini_cli -h