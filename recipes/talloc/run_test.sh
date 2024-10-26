#!/bin/bash

function cleanup {
    [ -f test_talloc.c ] && rm test_talloc.c
    [ -f test_talloc ] && rm test_talloc
}

trap cleanup EXIT

cat <<END >test_talloc.c
#include <talloc.h>

int
main(int argc, char *argv[]) {

char *str1 = talloc_strdup(NULL, "A talloc test");
printf("%s\n", str1);
talloc_free(str1);
exit(0);

}
END


gcc -I$PREFIX/include -L$PREFIX/lib -o test_talloc test_talloc.c -ltalloc
./test_talloc |grep talloc >/dev/null 2>&1

