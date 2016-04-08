#!/bin/bash
#Copyright (c) 2016, Medicine Yeh
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#2. Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#The views and conclusions contained in the software and documentation are those
#of the authors and should not be interpreted as representing official policies,
#either expressed or implied, of the FreeBSD Project.


_mmode()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--help distcc ccache both reset"

    if [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
complete -F _mmode mmode

function _mmode_print_help(){
    echo "mmode is a tool developed by Medicine Yeh to enable parallel compilation ability in an easy way"
    echo "Version: 1.0"
    echo ""
    echo "Usage:"
    echo "  reset          Reset bash to original state"
    echo "  distcc         Set bash to distcc state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo "  ccache         Set bash to ccache state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo "  both           Set bash to ccache + distcc state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo ""
}

function mmode() {
    #Environment Variables of mmode
    M_CC='gcc'
    M_CXX='g++'
    M_CPP="$M_CXX"
    #Read user setting if there is one
    if [ ! -z $DISTCC_HOSTS ]; then
        M_DISTCC_HOSTS=$DISTCC_HOSTS
    else
        M_DISTCC_HOSTS='localhost/2'
    fi

    # Blue "\[\033[44m\]"
    # High Itensity Blue "\[\033[0;104m\]"
    M_COLOR="\[\033[0;104m\]"
    M_NC="\[\033[0m\]"
    #Set to y if you want to make the state show before your PS1 setting
    M_PUT_BEFORE_PS1="n"

    case "$1" in
    "-h") _mmode_print_help;;
    "--help") _mmode_print_help;;
    "reset")
        alias make='make'
        [ "$ORIG_PS1" != '' ] && export PS1=$ORIG_PS1

        #Reset memory
        ORIG_PS1=''
        M_DISTCC_ENABLEED=''
        M_CCACHE_ENABLEED=''
        return 0
        ;;
    "distcc") M_DISTCC_ENABLEED='y' ;;
    "ccache") M_CCACHE_ENABLEED='y' ;;
    "both")
        M_DISTCC_ENABLEED='y'
        M_CCACHE_ENABLEED='y'
        ;;
    esac

    #Backup original env vars when it's first time
    [ "$ORIG_PS1" == '' ] && ORIG_PS1=$PS1

    #Set up env vars
    if [ "$M_DISTCC_ENABLEED" == 'y' ] && \
       [ "$M_CCACHE_ENABLEED" == 'y' ]; then
        if [ "$M_PUT_BEFORE_PS1" == 'y' ]; then
            export PS1="${M_COLOR}ccache${M_NC} ${M_COLOR}distcc${M_NC} "$ORIG_PS1
        else
            export PS1=$ORIG_PS1"${M_COLOR}ccache${M_NC} ${M_COLOR}distcc${M_NC} "
        fi
        export DISTCC_HOSTS=$M_DISTCC_HOSTS
        export CCACHE_PREFIX="distcc "
        M_NUM_CORES=$(distcc -j)
        M_MAKE_J=$(echo "${M_NUM_CORES} * 7 / 5" | bc)
        printf -v M_MAKE_ALIAS \
            'make CC="ccache %s" CXX="ccache %s" CPP="ccache %s" -j%d' \
            $M_CC $M_CXX $M_CPP $M_MAKE_J
        alias make=$M_MAKE_ALIAS
    elif [ "$M_DISTCC_ENABLEED" == 'y' ]; then
        if [ "$M_PUT_BEFORE_PS1" == 'y' ]; then
            export PS1="${M_COLOR}distcc${M_NC} "$ORIG_PS1
        else
            export PS1=$ORIG_PS1"${M_COLOR}distcc${M_NC} "
        fi
        export DISTCC_HOSTS=$M_DISTCC_HOSTS
        M_NUM_CORES=$(distcc -j)
        M_MAKE_J=$(echo "${M_NUM_CORES} * 7 / 5" | bc)
        printf -v M_MAKE_ALIAS \
            'make CC="distcc %s" CXX="distcc %s" CPP="distcc %s" -j%d' \
            $M_CC $M_CXX $M_CPP $M_MAKE_J
        echo $M_MAKE_ALIAS
        alias make=$M_MAKE_ALIAS
    elif [ "$M_CCACHE_ENABLEED" == 'y' ]; then
        if [ "$M_PUT_BEFORE_PS1" == 'y' ]; then
            export PS1="${M_COLOR}ccache${M_NC} "$ORIG_PS1
        else
            export PS1=$ORIG_PS1"${M_COLOR}ccache${M_NC} "
        fi
        export DISTCC_HOSTS=$M_DISTCC_HOSTS
        printf -v M_MAKE_ALIAS \
            'make CC="ccache %s" CXX="ccache %s" CPP="ccache %s" -j%d' \
            $M_CC $M_CXX $M_CPP $(nproc)
        alias make=$M_MAKE_ALIAS
    fi
}
#This is for updating shell state in case user source their shell config
mmode

#
# This is the end of mmode code
#

