#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "shuffle.h"


int main() {
    std::string dir = "shuf_file";
    system(("mkdir -p " + dir).c_str());

    std::vector<int> ks = {11, 10, 9, 8};
    std::vector<int> drlevels = {4, 3, 2};

    for (int drlevel : drlevels) {
        for (int k : ks) {
            dim_shuffle_stat_t shuffle_stat;
            shuffle_stat.k = k;
            shuffle_stat.subk = 6;
            shuffle_stat.drlevel = drlevel;

            std::string outputFile = dir + "/L" + std::to_string(drlevel) + "K" + std::to_string(k) + ".shuf";
            write_shuffle_dim_file(&shuffle_stat, outputFile);
        }
    }

    return 0;
}
