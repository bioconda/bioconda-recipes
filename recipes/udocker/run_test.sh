#!/bin/sh

MY_UID=`id -u`
TEST_USER=`id -un`
if [ $MY_UID -eq 0 ] ; then
    TEST_USER=testuser
    useradd $TEST_USER
fi

/usr/bin/sudo -E -u $TEST_USER sh <<"END"
PATH=$CONDA_PREFIX/bin:$PATH ; export PATH
udocker help | grep udocker >/dev/null
udocker pull hello-world && udocker run hello-world | grep 'Hello from Docker' >/dev/null
END
