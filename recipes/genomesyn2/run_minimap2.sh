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
    # echo "  align_commands   1 to run minimap2 alignment [default: 1] (optional)"
    exit 1
fi

# 参数赋值（带默认值）
ref_file=$1
query_file=$2
index_name=$3
threads_number=${4:-1}
align_commands=${5:-1}
sv_commands=${6:-1}
index_name=$(realpath "$index_name")
workdir=$(dirname "$index_name")
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$workdir"

# 检查 Minimap2 是否已安装
if ! command -v minimap2 &> /dev/null; then
        echo "⚠️ Warning: Minimap2 is not installed or not in PATH. Skipping Minimap2 search."
    exit 0
fi
# 判断是否执行minimap2对齐
for f in "${index_name}.paf"; do
    if [ -e "$f" ]; then
        echo "⚠️ Warning: File $f exists."
        align_commands=0
    fi
done

echo "ref:${ref_file}"
echo "query:${query_file}"
for f in "${ref_file}" "${query_file}"; do
    if [ ! -e "$f" ]; then
        echo "⚠️ Warning: Reference genome file $f does not exist."
        align_commands=0
    fi
done

# 如果执行minimap2比对
if [ "$align_commands" -eq 1 ]; then
    echo "⚙️ Running minimap2 alignment..."
    minimap2 -t "$threads_number" -cx asm10 "$ref_file" "$query_file" > "${index_name}.paf"
	$SCRIPT_PATH/minimap2_paf2tsv.pl --in "${index_name}.paf" --out "${index_name}.minimap2.tsv"
    if [ -e "${index_name}.paf" ]; then
        echo "✅ Alignment finished. Output: ${index_name}.paf"
    fi

else
    echo "⏭️ Skipping Minimap2 alignment."
fi

