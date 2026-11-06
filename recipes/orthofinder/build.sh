#!/bin/bash
set -euo pipefail

mkdir -p "$PREFIX/bin"

cp orthofinder.py "$PREFIX/bin/orthofinder"

mkdir -p "$PREFIX/bin/src/orthofinder"
cp -r src/orthofinder/* "$PREFIX/bin/src/orthofinder/"

mkdir -p "$PREFIX/bin/tools"
cp tools/*.py "$PREFIX/bin/tools/"
cp -r tools/view_results "$PREFIX/bin/tools/"

cat > "$PREFIX/bin/orthofinder-utils" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/list_tools.py" "$@"
EOF

cat > "$PREFIX/bin/primary_transcript" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/primary_transcript.py" "$@"
EOF

cat > "$PREFIX/bin/ncbi_primary_transcript" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/ncbi_primary_transcript.py" "$@"
EOF

cat > "$PREFIX/bin/make_ultrametric" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/make_ultrametric.py" "$@"
EOF

cat > "$PREFIX/bin/convert_orthofinder_tree_ids" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/convert_orthofinder_tree_ids.py" "$@"
EOF

cat > "$PREFIX/bin/create_hog_fastas" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/create_hog_fastas.py" "$@"
EOF

cat > "$PREFIX/bin/orthogroup_gene_count" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/orthogroup_gene_count.py" "$@"
EOF

cat > "$PREFIX/bin/split_ortholog_files" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/split_ortholog_files.py" "$@"
EOF

cat > "$PREFIX/bin/species_tree_alignment" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/species_tree_alignment.py" "$@"
EOF

cat > "$PREFIX/bin/mcl_orthogroup_sequences" <<'EOF'
#!/bin/bash
python "$CONDA_PREFIX/bin/tools/mcl_orthogroup_sequences.py" "$@"
EOF

chmod a+x "$PREFIX/bin/orthofinder"
chmod a+x "$PREFIX/bin/orthofinder-utils"
chmod a+x "$PREFIX/bin/primary_transcript"
chmod a+x "$PREFIX/bin/ncbi_primary_transcript"
chmod a+x "$PREFIX/bin/make_ultrametric"
chmod a+x "$PREFIX/bin/convert_orthofinder_tree_ids"
chmod a+x "$PREFIX/bin/create_hog_fastas"
chmod a+x "$PREFIX/bin/orthogroup_gene_count"
chmod a+x "$PREFIX/bin/split_ortholog_files"
chmod a+x "$PREFIX/bin/species_tree_alignment"
chmod a+x "$PREFIX/bin/mcl_orthogroup_sequences"

mkdir -p "$PREFIX/share/orthofinder/"
cp -r ExampleData "$PREFIX/share/orthofinder/"
