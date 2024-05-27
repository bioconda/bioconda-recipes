# Build and install gemBS
cargo build --release
echo test_addimator
ls -ahl
pwd
echo test_addimator
mkdir -p $PREFIX/bin
cp target/release/gemBS $PREFIX/bin/
