// Temporary CI probe: run the compiled native backend without the Rust worker.
#include <cstddef>
#include <cstdio>
extern "C" int tero_anim_orientation(const char*, const char*, const char*, char*, std::size_t);
int main(int argc, char** argv) {
    if (argc != 4) return 2;
    char error[1024] = {};
    const int result = tero_anim_orientation(argv[1], argv[2], argv[3], error, sizeof error);
    std::fprintf(stderr, "[DEBUG-bioconda-mac] native return=%d message=%s\n", result, error);
    return result;
}
