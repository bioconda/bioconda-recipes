cd rust
cp gemBS/Cargo.toml.in gemBS/Cargo.toml
cargo build --release
echo addi1
ls -ahl
echo addi2
ls -ahl target
echo addi3
ls -ahl target/release
echo addi4
cp target/release/gem_bs $prefix/bin/gemBS
cp target/release/read_filter $prefix/bin/
cp target/release/bs_call $prefix/bin/
cp target/release/snpxtr $prefix/bin/
cp target/release/mextr $prefix/bin/
cp target/release/dbsnp_index $prefix/bin/
