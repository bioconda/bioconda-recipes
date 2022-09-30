#!/bin/bash

# Usage: create-wrapper.sh <SCRIPT_PATH> <NEW_PATH>
#
#  - moves <SCRIPT_PATH> to <NEW_PATH>
#  - creates wrapper <SCRIPT_PATH>
#    - takes original shebang line
#    - removes prefix #!/bin or #!/usr/bin
#    - uses resulting command CMD for a call to `exec CMD <NEW_PATH> "$@"`

test ! -e "$2"
mv "$1" "$2"
chmod a-x "$2"

interpreter="$(sed -nE '1 s|^#! *(/usr)?/bin/||p;q' "$2")"
[ -n "${interpreter}" ]
cat >"$1" <<EOF
#!/bin/bash
exec ${interpreter} '$2' "\$@"
EOF

chmod u+x "$1"
