#!/usr/bin/env bash
set -euo pipefail

# Install package files
mkdir -p "$PREFIX/lib/tir-learner4"
cp -r TIR-Learner4/* "$PREFIX/lib/tir-learner4/"

# Fix shebang in main script (original has #!/usr/app/env python3, a typo)
sed -i '1s|.*|#!/usr/bin/env python3|' "$PREFIX/lib/tir-learner4/TIR-Learner.py"

# Create CLI wrapper
mkdir -p "$PREFIX/bin"
cat > "$PREFIX/bin/tirlearner4" << 'EOF'
#!/usr/bin/env bash
exec python3 "$(dirname "$(dirname "$(readlink -f "$0")")")/lib/tir-learner4/TIR-Learner.py" "$@"
EOF
chmod +x "$PREFIX/bin/tirlearner4"
