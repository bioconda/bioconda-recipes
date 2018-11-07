
#!/bin/bash -e -x
cd mtsv/ext
#cargo test
g++ -std=c++11 -pthread -static-libstdc++ ../mtsv_prep/taxidtool.cpp -o mtsv-db-build
cargo build --release
