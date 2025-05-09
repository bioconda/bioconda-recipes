#!/bin/bash
# Install the package using pip
$PYTHON -m pip install . --no-deps -vv

# Create the wrapper script for "reditools3"
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/reditools3 <<'EOF'
#!/bin/bash
exec python -m reditools "$@"
EOF
chmod +x $PREFIX/bin/reditools3