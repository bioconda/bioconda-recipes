#!/usr/bin/env python3

import os
import sys
import subprocess

DEFAULT_XMS = "-Xms512m"
DEFAULT_XMX = "-Xmx2g"

BIN_DIR = os.path.dirname(os.path.realpath(__file__))
PREFIX = os.path.dirname(BIN_DIR)
JAVA_PATH = os.path.join(BIN_DIR, "java")
JAR_PATH = os.path.join(PREFIX, "share", "kcftools", "kcftools.jar")

def split_jvm_opts(args):
    jvm_opts, app_args = [], []
    for arg in args:
        if arg.startswith("-Xms") or arg.startswith("-Xmx"):
            jvm_opts.append(arg)
        else:
            app_args.append(arg)
    return jvm_opts, app_args


def default_heap_opts():
    heap_size = os.environ.get("KCFTOOLS_HEAP_SIZE")
    if heap_size:
        return [DEFAULT_XMS, "-Xmx{}".format(heap_size)]
    return [DEFAULT_XMS, DEFAULT_XMX]


def main():
    if not os.access(JAVA_PATH, os.X_OK):
        sys.exit("Error: no executable java at {}.".format(JAVA_PATH))

    if not os.path.isfile(JAR_PATH):
        sys.exit("Error: could not find kcftools.jar at {}".format(JAR_PATH))

    jvm_opts, app_args = split_jvm_opts(sys.argv[1:])
    if not jvm_opts:
        jvm_opts = default_heap_opts()

    java_cmd = [JAVA_PATH] + jvm_opts + ["-jar", JAR_PATH] + app_args

    rc = subprocess.call(java_cmd)

    # flip dead child negative return code
    sys.exit(128 - rc if rc < 0 else rc)


if __name__ == "__main__":
    main()