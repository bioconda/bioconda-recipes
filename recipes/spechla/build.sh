#!/bin/bash
set -exuo pipefail

SHARE_DIR="${PREFIX}/share/spechla"

# --- Build SpecHap ---
mkdir -p bin/SpecHap/build
cd bin/SpecHap/build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release
make -j${CPU_COUNT}
make install
cd "${SRC_DIR}"

# --- Build ExtractHAIRs ---
mkdir -p bin/extractHairs/build
cd bin/extractHairs/build
cmake .. \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release
make -j${CPU_COUNT}
make install
cd "${SRC_DIR}"

# --- Install scripts to share dir ---
mkdir -p "${SHARE_DIR}/script"
cp -r script/* "${SHARE_DIR}/script/"

# --- Install database to share dir ---
mkdir -p "${SHARE_DIR}/db"
cp -r db/* "${SHARE_DIR}/db/"

# --- Install utility scripts to bin ---
install -m 755 bin/blast2sam.pl "${PREFIX}/bin/"
install -m 755 bin/vcf-combine.py "${PREFIX}/bin/"

# --- Generate HLA config files ---
HLAs=(A B C DPA1 DPB1 DQA1 DQB1 DRB1)
for hla in ${HLAs[@]}; do
    config_file="${SHARE_DIR}/db/HLA/HLA_${hla}.config.txt"
    echo "bwa=${SHARE_DIR}/db/HLA/HLA_${hla}/HLA_${hla}.fa" >"$config_file"
    echo "freebayes=${SHARE_DIR}/db/HLA/HLA_${hla}/HLA_${hla}.fa" >>"$config_file"
    echo "blat=${SHARE_DIR}/db/HLA/HLA_${hla}/" >>"$config_file"
done

# --- Build bowtie2 indexes ---
bowtie2-build "${SHARE_DIR}/db/ref/hla_gen.format.filter.extend.DRB.no26789.fasta" \
    "${SHARE_DIR}/db/ref/hla_gen.format.filter.extend.DRB.no26789.fasta"
bowtie2-build "${SHARE_DIR}/db/ref/hla_gen.format.filter.extend.DRB.no26789.v2.fasta" \
    "${SHARE_DIR}/db/ref/hla_gen.format.filter.extend.DRB.no26789.v2.fasta"

# --- Install wrapper: spechla ---
cat > "${PREFIX}/bin/spechla" << 'EOF'
#!/bin/bash
set -euo pipefail
export SPECHLA_DB="${SPECHLA_DB:-${CONDA_PREFIX}/share/spechla/db}"
export SPECHLA_SCRIPT="${SPECHLA_SCRIPT:-${CONDA_PREFIX}/share/spechla/script}"
exec bash "${SPECHLA_SCRIPT}/whole/SpecHLA.sh" "$@"
EOF
chmod +x "${PREFIX}/bin/spechla"

# --- Install wrapper: spechla-extract-hla-reads ---
cat > "${PREFIX}/bin/spechla-extract-hla-reads" << 'EOF'
#!/bin/bash
set -euo pipefail
export SPECHLA_DB="${SPECHLA_DB:-${CONDA_PREFIX}/share/spechla/db}"
export SPECHLA_SCRIPT="${SPECHLA_SCRIPT:-${CONDA_PREFIX}/share/spechla/script}"
exec bash "${SPECHLA_SCRIPT}/ExtractHLAread.sh" "$@"
EOF
chmod +x "${PREFIX}/bin/spechla-extract-hla-reads"

# --- Install wrapper: spechla-long-read ---
cat > "${PREFIX}/bin/spechla-long-read" << 'EOF'
#!/bin/bash
set -euo pipefail
export SPECHLA_DB="${SPECHLA_DB:-${CONDA_PREFIX}/share/spechla/db}"
export SPECHLA_SCRIPT="${SPECHLA_SCRIPT:-${CONDA_PREFIX}/share/spechla/script}"
exec python3 "${SPECHLA_SCRIPT}/long_read_typing.py" "$@"
EOF
chmod +x "${PREFIX}/bin/spechla-long-read"

# --- Install wrapper: spechla-assembly ---
cat > "${PREFIX}/bin/spechla-assembly" << 'EOF'
#!/bin/bash
set -euo pipefail
export SPECHLA_DB="${SPECHLA_DB:-${CONDA_PREFIX}/share/spechla/db}"
export SPECHLA_SCRIPT="${SPECHLA_SCRIPT:-${CONDA_PREFIX}/share/spechla/script}"
exec python3 "${SPECHLA_SCRIPT}/typing_from_assembly.py" "$@"
EOF
chmod +x "${PREFIX}/bin/spechla-assembly"

# --- Install wrapper: spechla-loh ---
cat > "${PREFIX}/bin/spechla-loh" << 'EOF'
#!/bin/bash
set -euo pipefail
export SPECHLA_DB="${SPECHLA_DB:-${CONDA_PREFIX}/share/spechla/db}"
export SPECHLA_SCRIPT="${SPECHLA_SCRIPT:-${CONDA_PREFIX}/share/spechla/script}"
exec perl "${SPECHLA_SCRIPT}/cal.hla.copy.pl" "$@"
EOF
chmod +x "${PREFIX}/bin/spechla-loh"
