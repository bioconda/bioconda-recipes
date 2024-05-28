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
cp gemBS $prefix/bin/gemBS
cp read_filter $prefix/bin/
cp bs_call $prefix/bin/
cp snpxtr $prefix/bin/
cp mextr $prefix/bin/
cp dbsnp_index $prefix/bin/
