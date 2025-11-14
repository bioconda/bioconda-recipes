#!/bin/bash

# 参数检查
if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <query_fasta> <target_fasta> <targetDB_prefix> <output_prefix> [threads_number]"
    echo
    echo "Example (default threads=1):"
    echo "    $0 query.pep.fa ref.pep.fa ref_db ref_vs_query.diamond"
    echo
    echo "Example:"
    echo "    $0 query.pep.fa ref.pep.fa ref_db ref_vs_query.diamond 1"
    echo
    echo "Parameters:"
    echo "  query_fasta      Query protein FASTA file              (required)"
    echo "  target_fasta     Target protein FASTA file             (required)"
    echo "  targetDB_prefix  Prefix for DIAMOND database           (required)"
    echo "  output_prefix    Prefix for Output file name           (required)"
    echo "  threads_number   Number of threads to use [default: 1] (optional)"
   #  echo "  align_commands        Whether to run blastp [default: 1] (0 = skip)"
    exit 1
fi

# 参数解析
index="$1"
target="$2"
db_prefix="$3"
output="$4"
threads="${5:-1}"
align_commands=1
output=$(realpath "$output")
workdir=$(dirname "$output")
cd "$workdir"
db_dir="${db_prefix}_DB"
cd "$workdir"

# 检查 diamond 是否已安装
if ! command -v diamond &> /dev/null; then
    echo "⚠️ Warning: DIAMOND is not installed or not in PATH. Skipping DIAMOND execution."
    exit 0
fi
# 判断是否执行diamond对齐
for f in "${output}"; do
    if [ -e "$f" ]; then
        echo "⚠️ Warning: File $f exists. Skipping DIAMOND alignment."
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

# 运行 blastp（可控制是否运行）
if [ "$align_commands" -eq 1 ]; then
    echo "🔍 Query: $index"
    echo "🎯 Target: $target"
    echo "📦 DB prefix: $db_prefix"
    echo "📄 Output: $output"
    echo "🧵 Threads: $threads"

    # 构建数据库名
    db="${db_prefix}dia_db"

    # 如果数据库不存在，则创建
    if [ ! -e "$db.dmnd" ]; then
        echo "📦 Building DIAMOND database: $db"
	mkdir "$db_dir"
        cd "$workdir/$db_dir"
        diamond makedb --in "$target" -d "$db"
    else
        echo "✅ DIAMOND database already exists: $db.dmnd"
    fi
    echo "🚀 Running DIAMOND blastp"
    diamond blastp -d "$db" -q "$index" -o "$output" -p "$threads" --evalue 1e-5 --max-target-seqs 1 --outfmt 6
    if [ ! -e "$output" ]; then
        echo "✅ BLASTP completed. Output saved to $output"
    fi
    echo "🎉 All done."
else
    echo "⏭️ Skipping diamond alignment."
fi

