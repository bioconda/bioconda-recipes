set -e

echo "Building deeploid_mini_cli..."

cp -r $SRC_DIR/* $PREFIX/

cd $PREFIX/bin
ls $PREFIX
ls $SRC_DIR

ln -s $PREFIX/deeploid_cli.py $SRC_DIR/deeploid_mini_cli
cd
chmod +x deeploid_mini_cli 
$PYTHON deeploid_mini_cli -h