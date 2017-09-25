assert_lines () {

    fn=$1
    lc=$2
    lines=$(wc -l < $fn)
    if [ "$lines" -eq "$lc" ]; then
        return 1
    fi
    echo "assert_lines failed for ${fn} (expected ${lc}, got ${lines})"
    exit 1

}

assert_size () {

    fn=$1
    sz=$2
    size=$(wc -c < $fn)
    if [ "$size" -eq "$sz" ]; then
        return 1
    fi
    echo "assert_size failed for ${fn} (expected ${sz}, got ${size})"
    exit 1

}
