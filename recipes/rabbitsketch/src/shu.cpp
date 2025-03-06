#include <iostream>
#include <fstream>
#include <string>
#include "shuffle.h"
#include "common.h"

using namespace std;

int main() {
    // 固定参数
    string outputFile = "shuf_file/L3K10.shuf";
    int half_k = 10;
    int half_subk = 6;
    int drlevel = 3;

    // 输出生成的 shuffle 文件
    cerr << "-----generate the shuffle file: " << outputFile << endl;

    // 设置 shuffle 参数
    dim_shuffle_stat_t shuffle_stat;
    shuffle_stat.k = half_k;
    shuffle_stat.subk = half_subk;
    shuffle_stat.drlevel = drlevel;

    // 调用 shuffle 生成函数
    write_shuffle_dim_file(&shuffle_stat, outputFile);

    return 0;
}

