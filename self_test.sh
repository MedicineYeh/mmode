#!/bin/bash

#This is a function to test all functionality of mmode on travis CI
M_AUTO_VERSION_DETECTION="n"
echo "$PS1"

echo "        *** Test reset ***"
echo ""
mmode reset
out=''
out=${out}$(echo $PS1 | grep "ccache")
out=${out}$(echo $PS1 | grep "distcc")
out=${out}${CCACHE_PREFIX}
out=${out}$(alias | grep "make")
echo "$out"
[[ -n "$out" ]] && return 1

echo "       *** Test distcc ***"
echo ""
mmode reset
mmode distcc
out=''
out=${out}$(echo $PS1 | grep "ccache")
out=${out}${CCACHE_PREFIX}
out=${out}$(alias | grep "make" | grep -v "distcc")
echo "$out"
[[ -n "$out" ]] && return 2

echo "        *** Test ccache ***"
echo ""
mmode reset
mmode ccache
out=''
out=${out}$(echo $PS1 | grep "distcc")
out=${out}${CCACHE_PREFIX}
out=${out}$(alias | grep "make" | grep -v "ccache")
echo "$out"
[[ -n "$out" ]] && return 3

echo "        *** Test distcc + ccache ***"
echo ""
mmode distcc
mmode ccache
out=''
[[ ! -n ${CCACHE_PREFIX} ]] && out=${out}" CCACHE_PREFIX FAIL"
out=${out}$(alias | grep "make" | grep -v "ccache")
out=${out}$(alias | grep "make" | grep "distcc")
echo "$out"
[[ -n "$out" ]] && return 4

echo "        *** Test both with M_AUTO_VERSION_DETECTION ***"
echo ""
mmode reset
M_AUTO_VERSION_DETECTION="y"
# Input yes for symbolic link confirmation
echo 'yes' | mmode both
out=''
[[ ! -n ${CCACHE_PREFIX} ]] && out=${out}" CCACHE_PREFIX FAIL"
out=${out}$(alias | grep "make" | grep -v "ccache")
out=${out}$(alias | grep "make" | grep "distcc")
out=${out}$(alias | grep "make" | grep -v "gcc-")
out=${out}$(alias | grep "make" | grep -v "g++-")
echo "$out"
[[ -n "$out" ]] && return 5

M_AUTO_VERSION_DETECTION="n"
#All pass
return 0

