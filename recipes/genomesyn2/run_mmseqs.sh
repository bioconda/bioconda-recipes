#!/bin/bash

# 参数个数检查
if [ "$#" -lt 5 ] || [ "$#" -gt 6 ]; then
    echo "Usage: $0 <index_fasta> <target_fasta> <db1_prefix> <db2_prefix> <output_file> [threads_number]"
    echo
    echo "Example (default threads=1):"
    echo "    $0 ref.pep.fa query.pep.fa ref_db query_db ref_vs_query.mmseqs.out"
    echo
    echo "Example (custom):"
    echo "    $0 ref.pep.fa query.pep.fa ref_db query_db ref_vs_query.mmseqs.out 1"
    exit 1
fi

# 获取参数
index="$1"
target="$2"
db1_prefix="$3"
db2_prefix="$4"
output="$5"
threads="${6:-1}"
align_commands=1
output=$(realpath "$output")
workdir=$(dirname "$output")
db1_dir="${db1_prefix}_DB"
db2_dir="${db2_prefix}_DB"
cd "$workdir"

# 数据库名称
db1="${db1_prefix}"
db2="${db2_prefix}"
prefix_db="${db1_prefix}_vs_${db2_prefix}_DB"
mkdir "${prefix_db}"
# 检查 mmseqs 是否已安装
if ! command -v mmseqs &> /dev/null; then
    echo "⚠️  Warning: mmseqs is not installed or not in PATH. Skipping mmseqs search."
    exit 0
fi
# 判断是否执行mmseqs对齐
for f in "${output}"; do
    if [ -e "$f" ]; then
        echo "⚠️ Warning: File $f exists."
        align_commands=0
    fi
done

echo "ref:${index}"
echo "query:${target}"
for f in "${index}" "${target}"; do
    if [ ! -e "$f" ]; then
        echo "⚠️ Warning: Reference genome file $f does not exist."
        align_commands=0
    fi
done

# 是否运行搜索
if [ "$align_commands" -eq 1 ]; then
    echo "🔍 Index FASTA: $index"
    echo "🎯 Target FASTA: $target"
    echo "📂 DB1: $db1"
    echo "📂 DB2: $db2"
    echo "📄 Output: $output"
    echo "🧵 Threads: $threads"
    cd "$workdir/$prefix_db"
    # 创建数据库（如果不存在）
    if [ ! -e "$db1" ]; then
        echo "📦 Creating database: $db1"
        mmseqs createdb "$index" "$db1"
    fi

    if [ ! -e "$db2" ]; then
        echo "📦 Creating database: $db2"
        mmseqs createdb "$target" "$db2"
    fi

    # 临时目录和结果前缀
    prefix="${db1_prefix}_vs_${db2_prefix}"
    tmp="${prefix}_tmp"
    result="${prefix}_result"

    # 清理旧临时目录
    if [ -d "$tmp" ]; then
        echo "🧹 Removing old tmp dir: $tmp"
        rm -rf "$tmp"
    fi
    mkdir "$tmp"
    echo "⚙️ Running mmseqs createindex..."
    mmseqs createindex "$db2" "$tmp"
    if [ $? -ne 0 ]; then
        echo "❌ Error: mmseqs createindex failed."
        exit 1
    fi

    echo "🚀 Running mmseqs search..."
    mmseqs search "$db1" "$db2" "$result" "$tmp" -e 1e-5 --threads "$threads" --max-seqs 1
    if [ $? -ne 0 ]; then
        echo "❌ Error: mmseqs search failed."
        exit 1
    fi

    echo "📄 Converting results to tab format..."
    mmseqs convertalis "$db1" "$db2" "$result" "$output"
    if [ $? -eq 0 ]; then
        echo "✅ Search complete. Output written to $output"
    else
        echo "⚠️ Warning: mmseqs convertalis failed. Output may be incomplete or missing."
        exit 1
    fi
else
    echo "⏭️ Skipping mmseqs alignment."
fi

if [ "$align_commands" -eq 1 ]; then
    # 清理临时文件
    echo "🧹 Cleaning intermediate result files..."
    for f in ${result}*; do
        [ -f "$f" ] && echo "  Deleting: $f" && rm "$f"
    done
    rm -rf "$tmp"
    echo "🎉 All done."
fi
