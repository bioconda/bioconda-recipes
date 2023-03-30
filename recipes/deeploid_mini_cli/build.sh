set -e

echo "Building deeploid_mini_cli..."

cp -r $SRC_DIR/* $PREFIX/

cd $PREFIX/bin
ln -s $PREFIX/deeploid_mini_cli.py ./deeploid_mini_cli
chmod +x ./deeploid_mini_cli 
cd
$PYTHON deeploid_mini_cli -h