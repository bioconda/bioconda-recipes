#!/bin/bash

# 参数个数不足或过多时提示用法
if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <query_fasta> <ref_fasta> <ref_db> <output_file> [threads_number]"
    echo "Example (default threads=1):"
    echo "    $0 query.pep.fa ref.pep.fa ref_db ref_vs_query.blast"
    echo
    echo "Example (custom):"
    echo "    $0 query.pep.fa ref.pep.fa ref_db ref_vs_query.blast 1"
    echo
    echo "Parameters:"
    echo "  query_fasta    Query protein FASTA file              (required)"
    echo "  ref_fasta      Target protein FASTA file             (required)"
    echo "  ref_db         Prefix for BLAST database & index     (required)"
    echo "  output_file    Output file name                      (required)"
    echo "  threads_number Number of threads to use [default: 1] (optional)"
    # echo "  run_blast     Whether to run BLASTP [default: 1] (0 = skip)"
    exit 1
fi

# 参数赋值
QUERY=$1
DB_FASTA=$2
DB_PREFIX=$3
OUTPUT=$4
# 自动生成默认输出文件名（如果未提供）
# QUERY_NAME=$(basename "$QUERY" | cut -d. -f1)
# DB_NAME=$(basename "$DB_FASTA" | cut -d. -f1)
# OUTPUT=${4:-${DB_NAME}vs${QUERY_NAME}.blast}
threads_number=${5:-1}
OUTPUT=$(realpath "$OUTPUT")
workdir=$(dirname "$OUTPUT")
db_dir="${DB_PREFIX}_DB"
cd "$workdir"

# 是否运行 BLASTP（默认 1）
align_commands=1

# 检查 BLAST+ 工具是否齐全
for tool in blastp makeblastdb; do
    if ! command -v "$tool" &> /dev/null; then
        echo "⚠️ Warning: $tool is not installed or not in PATH. Please install BLAST+."
        exit 0
    fi
done

# 判断是否执行blastp对齐
for f in "$OUTPUT"; do
    if [ -e "$f" ]; then
        echo "⚠️ Warning: File $f exists."
        align_commands=0
    fi
done

echo "ref:${QUERY}"
echo "query:${DB_FASTA}"
for f in "${QUERY}" "${DB_FASTA}"; do
    if [ ! -e "$f" ]; then
        echo "⚠️ Warning: Reference genome file $f does not exist."
        align_commands=0
    fi
done

# 运行 BLASTP（可选）
if [ "$align_commands" -eq 1 ]; then
    # 创建 BLAST 数据库
    echo "🧬 Building BLAST database: $DB_PREFIX"
    mkdir "$db_dir"
    cd "$workdir/$db_dir"
    makeblastdb -in "$DB_FASTA" -dbtype prot -parse_seqids -out "$DB_PREFIX" -logfile "${DB_PREFIX}.log" -title "$DB_PREFIX"
    echo "🚀 Running BLASTP: $QUERY vs $DB_PREFIX"
    blastp -query "$QUERY" -db "$DB_PREFIX" -out "$OUTPUT" -evalue 1e-10 -num_threads "$threads_number" -outfmt 6 -num_alignments 1 2> >(grep -v "Warning" >&2)
    if [ ! -e "$OUTPUT" ]; then
    echo "✅ BLASTP completed. Output saved to $OUTPUT"
    fi
else
    echo "⏭️ Skipping BLAST alignment."
fi

