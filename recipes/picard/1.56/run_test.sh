#!/bin/bash
# Conda sources this file; isolate test options and environment from later tests.
(
# Exercise the installed launcher with a stub JVM, without evaluating arguments.
set -eo pipefail

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
prefix="$workdir/prefix with spaces"
jar_dir="$prefix/share/picard-test"
mkdir -p "$prefix/bin" "$jar_dir"
cp -L "$(command -v picard)" "$jar_dir/picard"
ln -s ../share/picard-test/picard "$prefix/bin/picard"
cat > "$prefix/bin/java" <<'JAVA'
#!/bin/bash
printf '%s\0' "$@" > "$PICARD_TEST_ARGV"
exit "${PICARD_TEST_EXIT:-0}"
JAVA
chmod +x "$prefix/bin/java" "$jar_dir/picard"
export PATH="$prefix/bin:$PATH"
export PICARD_TEST_ARGV="$workdir/argv"
unset JAVA_HOME _JAVA_OPTIONS
cd "$workdir"

assert_argv() {
    printf '%s\0' "$@" > "$workdir/expected"
    if ! cmp -s "$workdir/expected" "$PICARD_TEST_ARGV"; then
        echo 'Picard launcher changed argument values or boundaries' >&2
        exit 1
    fi
    test ! -e injected
}

command_args=(MarkDuplicates.jar)
jar_selector=(MarkDuplicates.jar)
tool_args=()
jar="$jar_dir/MarkDuplicates.jar"
values=(--READ_NAME_REGEX '$(printf x > injected)' '`printf x > injected`'
        'x"; printf x > injected; #' '' 'two words' "O'Brien" 'a"b'
        '^([0-9]+):(\d+):(\d+)$' '*' '$PATH' $'one\ntwo')
picard -Xmx64m '-Dlabel=two words' '-Dliteral=$(printf x > injected)' \
    '-XX:ActiveProcessorCount=1' "${command_args[@]}" "${values[@]}"
assert_argv -Xmx64m '-Dlabel=two words' '-Dliteral=$(printf x > injected)' \
    '-XX:ActiveProcessorCount=1' -jar "$jar" "${tool_args[@]}" "${values[@]}"

# Also exercise JAVA_HOME with a path containing spaces.
export JAVA_HOME="$workdir/java home"
mkdir -p "$JAVA_HOME/bin"
ln -s "$prefix/bin/java" "$JAVA_HOME/bin/java"
picard -Xmx64m "${jar_selector[@]}" org.example.Main 'two words'
assert_argv -Xmx64m -cp "$jar" org.example.Main 'two words'

picard "${command_args[@]}"
assert_argv -Xms512m -Xmx1g -jar "$jar" "${tool_args[@]}"
export _JAVA_OPTIONS=''
picard "${command_args[@]}"
assert_argv -Xms512m -Xmx1g -jar "$jar" "${tool_args[@]}"
export _JAVA_OPTIONS='-Xmx900m -Xms64m'
picard "${command_args[@]}"
assert_argv -Xms512m -Xmx1g -jar "$jar" "${tool_args[@]}"

export PICARD_TEST_EXIT=23
status=0
picard -Xmx64m "${command_args[@]}" || status=$?
test "$status" -eq 23
echo 'Picard launcher argument and shell-injection tests passed'
)
