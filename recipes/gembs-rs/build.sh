pwd
cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
ls -ahl
ls -ahl gemBS
ls -ahl snpxtr
echo test_addimator

# Build and install gemBS
cargo build --release
mkdir -p $PREFIX/bin
cp target/release/gemBS $PREFIX/bin/
