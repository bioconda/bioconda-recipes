cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release

mkdir -p $PREFIX/bin
cp -r gemBS $PREFIX/bin/gemBS
echo addi1
ls -ahl
echo addi2
ls -ahl target
echo addi3
ls -ahl target/release
ls $PREFIX/bin/
chmod +x $PREFIX/bin/gemBS
