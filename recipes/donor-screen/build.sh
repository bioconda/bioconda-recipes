#!/bin/bash
set -euo pipefail
target="$PREFIX/share/donor-screen"
mkdir -p "$PREFIX/bin" "$target"
install -m 644 workflow/src/{donor-screen,donor_hbd.R,build_panel.py,screen.py,missense_screen.py,build_coding_pairs.py,report.py,observed_roh.py,predict_roh.py,report_locale.py} "$target/"
install -m 644 beagle-jar/beagle.25Mar22.4f6.jar "$target/"
cat > "$PREFIX/bin/donor-screen" <<'EOF'
#!/bin/bash
set -euo pipefail
prefix="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tool="$prefix/share/donor-screen"
export BEAGLE_JAR="${BEAGLE_JAR:-$tool/beagle.25Mar22.4f6.jar}"
exec "$prefix/bin/python" "$tool/donor-screen" "$@"
EOF
chmod 755 "$PREFIX/bin/donor-screen"
