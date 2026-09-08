#!/usr/bin/env bash
set -euo pipefail

# Install package files
mkdir -p "$PREFIX/lib/tir-learner4"
cp -r TIR-Learner4/* "$PREFIX/lib/tir-learner4/"

# Fix shebang in main script (original has #!/usr/app/env python3, a typo)
sed -i '1s|.*|#!/usr/bin/env python3|' "$PREFIX/lib/tir-learner4/TIR-Learner.py"

# Create CLI wrapper. TIR-Learner is the canonical command name, and what EDTA
# locates via `command -v TIR-Learner`, so install directly under it.
mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/TIR-Learner" << EOF
#!/usr/bin/env bash
exec python3 "$PREFIX/lib/tir-learner4/TIR-Learner.py" "\$@"
EOF
chmod +x "$PREFIX/bin/TIR-Learner"

# Also expose tirlearner4 as an alias of the default TIR-Learner command
ln -sf TIR-Learner "$PREFIX/bin/tirlearner4"
