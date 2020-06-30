#!/bin/sh

rm -fR test
mkdir test
cd test || exit -1

curl --insecure "https://www.lua.org/tests/lua-5.4.0-tests.tar.gz" > test.tgz
tar -xzf test.tgz
rm -fR test.tgz
mv */ test_suite
cp -r ../src ./
mv test_suite src
cp ../Makefile ./
cp src/test_suite/ltests/* src/

cd src/test_suite
cp ../../../script/doattr.lua ./
sed "s:dofile('files.lua'):dofile('doattr.lua'); dofile('files.lua'):g" -i all.lua
cd -

make linux
cd src/test_suite/libs
make
cd ..

../lua all.lua

cd ..
#rm -fR test

