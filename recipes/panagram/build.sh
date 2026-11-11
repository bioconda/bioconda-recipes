#!/bin/bash
set -euxo pipefail

# The v1.1.0 tag still reports 1.0.1.
sed -i.bak 's/^__version__ = .*/__version__ = "'"${PKG_VERSION}"'"/' panagram/__about__.py

# setup.py's build_py hook compiles KMC and downloads KMC and Mash binaries; bioconda supplies both.
sed -i.bak "s/cmdclass={'build_py': pre_build},//" setup.py

# Panagram runs its tools as panagram/extra/<tool>; point those at the env's bin/
# (extra/ is lib/pythonX.Y/site-packages/panagram/extra), so no activation is needed.
for tool in kmc kmc_tools kmc_dump mash; do
  cat > "panagram/extra/${tool}" <<EOF
#!/bin/sh
bin=\$(cd "\$(dirname "\$0")/../../../../../bin" 2>/dev/null && pwd)
[ -x "\${bin}/${tool}" ] && exec "\${bin}/${tool}" "\$@"
exec ${tool} "\$@"
EOF
  chmod +x "panagram/extra/${tool}"
done

${PYTHON} -m pip install . --no-deps --no-build-isolation -vv
