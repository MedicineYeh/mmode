# Introduction
__mmode__ is a tool to enable super fast compilation ability in an easy way.
It supports `ccache`, `distcc` and `ccache+distcc` modes.

[![Build Status](https://travis-ci.org/MedicineYeh/mmode.svg?branch=master)](https://travis-ci.org/MedicineYeh/mmode)
__mmode__ support `bash` and `zsh` shells!!

# Usage
Execute `mmode --help` to see more information of the commands.

After changing the mode, you can simply execute `make` to compile your projects without __-j__.
__mmode__ automatically choose the optimal number for your compilation.
If you want to override the number of parallel compilation, execute `make -jX` instead, where X is the number you specify.

# Prerequests
* [distcc](https://github.com/distcc/distcc)
* [ccache](https://ccache.samba.org/)

Normally, you can install them by your package manager.

# Settings
## distcc
You have to specify `DISTCC_HOSTS` in the script in order to connect distcc server.
You can also use `DISTCC_HOSTS` environment variable to specify the distcc servers.

## Compiler (Version)
You can change the default compiler by changing `M_CC` and `M_CXX` in the script.
Then, `source ~/.bashrc` to update the shell env vars.

## Color
You can change the color code `M_BASH_COLOR` and `M_ZSH_COLOR` to a proper color.
The color codes are listed here.
* [bash](http://misc.flogisoft.com/bash/tip_colors_and_formatting)
* zsh: Execute `spectrum_ls` and `spectrum_bls` for foreground and background colors, respectively.

## Position of state info in PS1
Set `M_PUT_BEFORE_PS1` to __y__ if you want to change the position of state info to the beginning.

# Installation
1. Copy mmode.sh to `~/.mmode.sh` by `cp ./mmode.sh ~/.mmode.sh`
2. Add the following lines to your `~/.bashrc`, `~/.bash_profile`, etc.
``` bash
source ~/.mmode.sh
```
Then, execute `source ~/.bashrc` (Your shell config file).

# License
FreeBSD License

