
set -ex

RUST_BACKTRACE=full

cargo install -v --locked --root "$PREFIX" --path .
