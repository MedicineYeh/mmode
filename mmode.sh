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

#Environment Variables of mmode
M_CC='gcc'
M_CXX='g++'
M_CPP="$M_CXX"
#Override env var here if you want
#DISTCC_HOSTS='localhost/2'

# Blue "\[\033[44m\]"
# High Itensity Blue "\[\033[0;104m\]"
M_BASH_COLOR='\[\033[0;104m\]'
M_BASH_NC='\[\033[0m\]'
#Color for zsh. Note: Not all background colors are supported by some teerminals.
#Here are possible names of colors
#   black blink blue conceal cyan green magenta red white yellow
M_ZSH_COLOR='%K{blue}%F{white}'
M_ZSH_NC='%{$reset_color%}'
#Set to y if you want to make the state show before your PS1 setting
M_PUT_BEFORE_PS1="n"
#Set to y if you want to use the version detection function
#If distcc servers have all versions of gcc, set this to y could improve compatibility
M_AUTO_VERSION_DETECTION="n"

# DO NOT EDIT THE VARIABLES AFTER THIS LINE UNLESS YOU KNOW THE RISK!!
# DO NOT EDIT THE VARIABLES AFTER THIS LINE UNLESS YOU KNOW THE RISK!!
# DO NOT EDIT THE VARIABLES AFTER THIS LINE UNLESS YOU KNOW THE RISK!!
function _mmode_bash() {
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

function _mmode_zsh() {
    local -a options
    options=('--help:Display help message and information of usage!!!' \
             'reset:Reset shell to original mode' \
             'distcc:Set shell to distcc state. alias CC,CXX,CPP in "make" with the optimal number of -j' \
             'ccache:Set shell to ccache state. alias CC,CXX,CPP in "make" with the optimal number of -j' \
             'both:Set shell to ccache + distcc state. alias CC,CXX,CPP in "make" with the optimal number of -j' \
            )
    _describe 'values' options
}

if [[ -n "$ZSH_VERSION" ]]; then
    # assume Zsh
    compdef _mmode_zsh mmode
    autoload colors && colors
    M_COLOR="$M_ZSH_COLOR"
    M_NC="$M_ZSH_NC"
elif [[ -n "$BASH_VERSION" ]]; then
    # assume Bash
    complete -F _mmode_bash mmode
    M_COLOR="$M_BASH_COLOR"
    M_NC="$M_BASH_NC"
else
    # asume something else
    echo "No completion support in this shell";
    M_COLOR="$M_BASH_COLOR"
    M_NC="$M_BASH_NC"
fi


function _mmode_ask_confirm()
{
    local user_decision=""

    echo $1
    read -p "contiune[yes/no]? " user_decision

    while [ "yes" != "${user_decision}" -a "no" != "${user_decision}" ]
    do
        read -p "contiune[yes/no]?, please answer 'yes' or 'no': " user_decision
    done

    [ "yes" == "${user_decision}" ] && return 0
    return 1
}

function _mmode_set_ps1() {
    local mode_str
    mode_str="${M_COLOR}${1}${M_NC} "
    [[ -n "$2" ]] && mode_str=${mode_str}"${M_COLOR}${2}${M_NC} "

    if [[ "$M_PUT_BEFORE_PS1" == 'y' ]]; then
        export PS1=${mode_str}$ORIG_PS1
    else
        export PS1=${ORIG_PS1}${mode_str}
    fi
}

function _mmode_set_gcc_version() {
    local gcc_ver

    #Initialize to the default value
    M_CC_V="$M_CC"
    M_CXX_V="$M_CXX"
    M_CPP_V="$M_CPP"

    gcc_ver=$(${M_CC} --version | head -n1 | cut -d' ' -f3 | cut -d'.' -f1,2)
    if [[ -n "$gcc_ver" ]] && [[ "$M_AUTO_VERSION_DETECTION" == "y" ]]; then
        if [[ ! -f "/bin/gcc-${gcc_ver}" ]]; then
            echo "Creating symbolic link for gcc-${gcc_ver}?"
            echo '    Set M_AUTO_VERSION_DETECTION="n" to disable this function'
            if [[ "$(_mmode_ask_confirm)" == "1" ]]; then
                sudo ln -s "/bin/$M_CC" "/bin/gcc-${gcc_ver}"
                sudo ln -s "/bin/$M_CXX" "/bin/g++-${gcc_ver}"
                sudo chmod +x "/bin/gcc-${gcc_ver}"
                sudo chmod +x "/bin/g++-${gcc_ver}"
            fi
        fi
        M_CC_V="gcc-${gcc_ver}"
        M_CXX_V="g++-${gcc_ver}"
        M_CPP_V="g++-${gcc_ver}"
    fi
}

function _mmode_print_help(){
    echo "mmode is a tool developed by Medicine Yeh to enable parallel compilation ability in an easy way"
    echo "Version: 1.0"
    echo ""
    echo "Usage:"
    echo "  --help         Display This help message"
    echo "  reset          Reset shell to original mode"
    echo "  distcc         Set shell to distcc state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo "  ccache         Set shell to ccache state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo "  both           Set shell to ccache + distcc state. alias CC,CXX,CPP in 'make' with the optimal number of -j"
    echo ""
    echo "Helpful Notes/Features:"
    echo "    If you have the same gcc toolchain version on the distcc servers, "
    echo "    you don't need to change any setting in the script."
    echo ""
    echo "  RUN ANY VERSION OF GCC ON YOUR COMPUTER:"
    echo "    If you have a distcc servers which have all versions of gcc (the future features of this tool),"
    echo "    you can set M_AUTO_VERSION_DETECTION=\"y\" to enable the compatibility function."
    echo "    Once you have set this flag to \"y\", the gcc version on your computer won't matter at all."
    echo "    This tool will automatically help you to set correct settings to make your distcc works (on the client side)."
    echo "    You can still use any gcc version you have on your computer by setting \"M_CC\" and \"M_CXX\" variables in the script."
    echo ""
    echo "  HOW TO SPECIFY -j FOR YOUR MAKE:"
    echo "    You can easily add \"-jX\" to your make command. The argument will override the original one in the alias."
    echo "    No matter what number of \"-j\" is in the alias, you always can force the number to be any number you want."
    echo "    For example: "
    echo "        make -j4"
    echo ""
    echo "  HOW TO SPECIFY COMPILER VERSION:"
    echo "    Modify the variables, \"M_CC\" and \"M_CXX\" in this script."
    echo ""
}

function mmode() {
    local num_cores num_j make_alias

    case "$1" in
    "-h") _mmode_print_help;;
    "--help") _mmode_print_help;;
    "reset")
        [[ -n "$(alias | grep 'colormake')" ]] && unalias colormake
        [[ -n "$(alias | grep 'make')" ]] && unalias make
        [ "$ORIG_PS1" != '' ] && export PS1=$ORIG_PS1

        #Reset memory
        ORIG_PS1=''
        M_DISTCC_ENABLEED=''
        M_CCACHE_ENABLEED=''
        export CCACHE_PREFIX=''
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
    [[ "$ORIG_PS1" == '' ]] && ORIG_PS1=$PS1

    _mmode_set_gcc_version

    #Set up env vars
    if [[ "$M_DISTCC_ENABLEED" == 'y' ]] && \
       [[ "$M_CCACHE_ENABLEED" == 'y' ]]; then
        _mmode_set_ps1 "ccache" "distcc"
        num_cores=$(distcc -j)
        num_j=$(echo "${num_cores} * 7 / 5" | bc)
        make_alias=$(printf \
            'CC="ccache %s" CXX="ccache %s" CPP="ccache %s" -j%d' \
            $M_CC_V $M_CXX_V $M_CPP_V $num_j)
        #Only set this when use both
        export CCACHE_PREFIX="distcc "
    elif [[ "$M_DISTCC_ENABLEED" == 'y' ]]; then
        _mmode_set_ps1 "distcc"
        num_cores=$(distcc -j)
        num_j=$(echo "${num_cores} * 7 / 5" | bc)
        make_alias=$(printf \
            'CC="distcc %s" CXX="distcc %s" CPP="distcc %s" -j%d' \
            $M_CC_V $M_CXX_V $M_CPP_V $num_j)
    elif [[ "$M_CCACHE_ENABLEED" == 'y' ]]; then
        _mmode_set_ps1 "ccache"
        make_alias=$(printf \
            'CC="ccache %s" CXX="ccache %s" CPP="ccache %s" -j%d' \
            $M_CC_V $M_CXX_V $M_CPP_V $(nproc))
    else
        #Exit when there is no mode set. The following lines are common actions
        return 0;
    fi

    alias make='make '$make_alias
    alias colormake='colormake '$make_alias
    #Show current settings of env vars
    echo "Current settings:"
    echo "  CCACHE_PREFIX=$CCACHE_PREFIX"
    echo "  alias make='make $make_alias'"
    echo "  alias colormake='colormake $make_alias'"
}
#This is for updating shell state in case user source their shell config
mmode

function _mmode_self_test() {
    #This is a function to test all functionality of mmode on travis CI
    M_AUTO_VERSION_DETECTION="n"
    echo "        *** Test reset ***"
    echo ""
    mmode reset
    out=''
    out=${out}$(echo $PS1 | grep "ccache")
    out=${out}$(echo $PS1 | grep "distcc")
    out=${out}${CCACHE_PREFIX}
    out=${out}$(alias | grep "make")
    echo "$out"
    [[ -n "$out" ]] && return -1

    echo "       *** Test distcc ***"
    echo ""
    mmode reset
    mmode distcc
    out=''
    out=${out}$(echo $PS1 | grep "ccache")
    out=${out}${CCACHE_PREFIX}
    out=${out}$(alias | grep "make" | grep -v "distcc")
    echo "$out"
    [[ -n "$out" ]] && return -1

    echo "        *** Test ccache ***"
    echo ""
    mmode reset
    mmode ccache
    out=''
    out=${out}$(echo $PS1 | grep "distcc")
    out=${out}${CCACHE_PREFIX}
    out=${out}$(alias | grep "make" | grep -v "ccache")
    echo "$out"
    [[ -n "$out" ]] && return -1

    echo "        *** Test distcc + ccache ***"
    echo ""
    mmode distcc
    mmode ccache
    out=''
    [[ ! -n ${CCACHE_PREFIX} ]] && out=${out}" CCACHE_PREFIX FAIL"
    out=${out}$(alias | grep "make" | grep -v "ccache")
    out=${out}$(alias | grep "make" | grep "distcc")
    echo "$out"
    [[ -n "$out" ]] && return -1

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
    [[ -n "$out" ]] && return -1

    M_AUTO_VERSION_DETECTION="n"
    #All pass
    return 0
}

#
# This is the end of mmode code
#

