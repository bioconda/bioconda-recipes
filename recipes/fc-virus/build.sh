#!/bin/bash


# 编译源代码
#make

# 运行编译好的程序
#echo "运行程序..."
#./bin/fc-virus

echo "克隆代码库..."
git clone https://github.com/qdu-bioinfo/FC-Virus.git

# 进入目录
cd FC-Virus/bin || { echo "进入目录失败"; exit 1; }
ls -l
# 清理和编译
#echo "清理旧文件并编译..."
#make clean && make || { echo "编译失败"; exit 1; }

# 运行编译好的程序
echo "运行程序..."
chmod +x fc-virus
fc-virus --help || { echo "运行程序失败"; exit 1; }
