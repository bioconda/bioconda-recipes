set -e

echo "Building deeploid_mini_cli..."

cp -r $SRC_DIR/* $PREFIX/

cd $PREFIX/bin
ls $SRC_DIR

ln -s $SRC_DIR/deeploid_cli.py deeploid_mini_cli
chmod +x deeploid_mini_cli 
deeploid_mini_cli -h
cd