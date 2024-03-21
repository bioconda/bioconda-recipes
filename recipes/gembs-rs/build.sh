ls -ahl
cd rust
ls -ahl
cargo build --release
cp target/release/gem_bs $prefix/bin/gemBS
cp target/release/read_filter $prefix/bin/
cp target/release/bs_call $prefix/bin/
cp target/release/snpxtr $prefix/bin/
cp target/release/mextr $prefix/bin/
cp target/release/dbsnp_index $prefix/bin/
