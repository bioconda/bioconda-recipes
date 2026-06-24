#!/usr/bin/env python3

import os
import sys
import subprocess

DEFAULT_XMS = "-Xms512m"
DEFAULT_XMX = "-Xmx2g"

def has_memory_opts(args):
    """Check if any -Xms or -Xmx options are already passed."""
    return any(arg.startswith("-Xms") or arg.startswith("-Xmx") for arg in args)

def get_heap_opts():
    """Get heap size options from env var if available."""
    heap_size = os.environ.get("KCFTOOLS_HEAP_SIZE")
    if heap_size:
        return [DEFAULT_XMS, f"-Xmx{heap_size}"]
    else:
        return [DEFAULT_XMS, DEFAULT_XMX]

def main():
    conda_prefix = os.environ.get("CONDA_PREFIX", "")
    if not conda_prefix:
        print("Error: CONDA_PREFIX is not set. Are you running inside a conda environment?", file=sys.stderr)
        sys.exit(1)

    jar_path = os.path.join(conda_prefix, "share", "kcftools", "kcftools.jar")
    if not os.path.isfile(jar_path):
        print(f"Error: Could not find kcftools.jar at {jar_path}", file=sys.stderr)
        sys.exit(1)

    java_cmd = ["java"]

    if not has_memory_opts(sys.argv[1:]):
        java_cmd.extend(get_heap_opts())

    java_cmd.extend(["-jar", jar_path])
    java_cmd.extend(sys.argv[1:])

    try:
        result = subprocess.run(java_cmd)
        sys.exit(result.returncode)
    except FileNotFoundError:
        print("Error: Java is not installed or not available in PATH.", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
#EOF
