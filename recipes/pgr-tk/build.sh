
git clone https://github.com/cschin/agc.git
pushd agc
git checkout 453c0afdc54b4aa00fa8e97a63f196931fdb81c4
popd

pushd rs-wfa/
rm -rf WFA
git clone https://github.com/cschin/WFA.git --depth=1
pushd WFA
git checkout 0c6000fc7c4208b048a27569e39904107fadd49d
popd
popd

echo $PREFIX
mkdir -p $BUILD_PREFIX/.cargo
export CARGO_HOME=$BUILD_PREFIX/.cargo

#rustup default stable
export LIBCLANG_PATH=$PREFIX/lib/

## TODO: using environmental variables in the libwfa makefile in the future. 
## The current compiler names are hard-coded in the makefile, so we need these symbolic links
ln -sf $CC $PREFIX/bin/gcc
ln -sf $CXX $PREFIX/bin/g++
export PATH=$PREFIX/bin:$PATH

cargo build -p libwfa --release
cargo build -p pgr-db --release
cargo build -p pgr-bin --release
cargo install maturin
export PATH=$CARGO_HOME/bin:$PATH
pushd pgr-tk/
#maturin build --release
maturin build --release --skip-auditwheel
popd

$PYTHON -m pip install $SRC_DIR/target/wheels/pgrtk-0.3.4-cp38-cp38-linux_x86_64.whl  --no-deps --ignore-installed --no-cache-dir -vvv
cp $SRC_DIR/target/release/pgr-mdb $PREFIX/bin
rm $PREFIX/bin/gcc
rm $PREFIX/bin/g++

