#!/bin/bash

# 参数个数不足时提示基本用法
if [ "$#" -lt 3 ] || [ "$#" -gt 4 ] || [ "$#" -gt 5 ]; then
    echo "Usage: $0 <ref_file> <query_file> <index_name> [threads_number]"
    echo
    echo "Example (default threads=1):"
    echo "    $0 ref.fasta query.fasta ref_vs_query"
    echo
    echo "Example (custom):"
    echo "    $0 ref.fasta query.fasta ref_vs_query 1"
    echo
    echo "Parameters:"
    echo "  ref_file         Reference genome FASTA file            (required)"
    echo "  query_file       Query genome FASTA file                (required)"
    echo "  index_name       Prefix name for output files           (required)"
    echo "  threads_number   Number of threads to use [default: 1]  (optional)"
    # echo "  sv_commands      1 to run SV detection [default: 1]     (optional)"
    exit 1
fi

# 参数赋值（带默认值）
ref_file=$1
query_file=$2
index_name=$3
threads_number=${4:-1}
sv_commands=${5:-1}
align_commands=1
index_name=$(realpath "$index_name")
workdir=$(dirname "$index_name")
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$workdir"

# 检查 MUMmer 是否已安装（通过检测 nucmer 是否可用）
if ! command -v nucmer &> /dev/null; then
	echo "⚠️ Warning: MUMmer (nucmer) is not installed or not in PATH. Skipping MUMmer search."
    exit 0
fi

# 判断是否执行mummer对齐
for f in "${index_name}.delta" "${index_name}.delta.filter" "${index_name}.coords"; do
    if [ -e "$f" ]; then
	echo "⚠️ Warning: File $f exists."
        align_commands=0
    fi
done

echo "ref:${ref_file}"
echo "query:${query_file}"
for f in "${ref_file}" "${query_file}"; do
    if [ ! -e "$f" ]; then
	echo "⚠️ Warning: Genome file $f does not exist."
        align_commands=0
    fi
done

if [ "$align_commands" -eq 1 ]; then
    echo "🚀 Running MUMmer alignment..."
    nucmer -g 1000 -c 90 -l 40 -t "$threads_number" -p "$index_name" "$ref_file" "$query_file"
    delta-filter -r -q -l 1000 "$index_name.delta" > "$index_name.delta.filter"
    show-coords -TrHcl "$index_name.delta.filter" > "$index_name.coords"
    $SCRIPT_PATH/mummer_coords2tsv.pl --in "$index_name.coords" --out "$index_name.mummer.tsv"
    if [ -e "$index_name.coords" ]; then
        echo "✅ Alignment finished. Output: $index_name.coords"
    fi
else
     echo "⏭️ Skipping MUMmer alignment."
fi

