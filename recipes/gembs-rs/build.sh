# Build and install gemBS
cargo build --release
echo test_addimator
ls -ahl
pwd
echo test_addimator
mkdir -p $PREFIX/bin
cp target/release/gemBS $PREFIX/bin/


echo addi1
ls -ahl
cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
echo addi2
ls -ahl
cargo build --release
echo addi3
ls -ahl
cp target/release/gem_bs $prefix/bin/gemBS
cp target/release/read_filter $prefix/bin/
cp target/release/bs_call $prefix/bin/
cp target/release/snpxtr $prefix/bin/
cp target/release/mextr $prefix/bin/
cp target/release/dbsnp_index $prefix/bin/
