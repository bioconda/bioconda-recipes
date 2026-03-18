#!/usr/bin/env bash
set -ex

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/share/knotAnnotSV"

cp -R -- * "$PREFIX/share/knotAnnotSV"

# Shebang is not generic -> create Bash wrappers:
cat << 'EOF' > "$PREFIX/bin/knotAnnotSV"
#!/usr/bin/env bash
perl "$PREFIX/share/knotAnnotSV/knotAnnotSV.pl" "$@"
EOF

cat << 'EOF' > "$PREFIX/bin/knotAnnotSV2XL"
#!/usr/bin/env bash
perl "$PREFIX/share/knotAnnotSV/knotAnnotSV2XL.pl" "$@"
EOF

chmod +x "$PREFIX"/bin/*
