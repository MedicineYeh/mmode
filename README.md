# Introduction
__mmode__ is a tool to enable super fast compilation ability in an easy way.
It supports ccache, distcc and ccache+distcc modes.

# Usage
Execute `mmode --help` to see more information of the commands.

After changing the mode, you can simply execute `make` to compile your projects without __-j__.
__mmode__ automatically choose the optimal number for your compilation.
If you want to override the number of parallel compilation, execute `make -jX` instead, where X is the number you specify.

# Prerequests
* (distcc)[https://github.com/distcc/distcc]
* (ccache)[https://ccache.samba.org/]

Normally, you can install them by your package manager.

# Settings
## distcc
You can start to use __mmode__ without settings.
However, you have to specify `M_DISTCC_HOSTS` in the script in order to connect distcc server.
You can also use `DISTCC_HOSTS` environment variable to specify the distcc servers.

## Color
You can change the color code `M_COLOR` to a proper color.
The color code is listed (here)[http://mediadoneright.com/content/ultimate-git-ps1-bash-prompt].

## Position of state
Set `M_PUT_BEFORE_PS1` to __y__ if you want to change the position of state info to the beginning.

# Installation
Copy mmode.sh to `~/.mmode.sh` and add the following lines to your `~/.bashrc`, `~/.bash_profile`, etc.
``` bash
source ~/.mmode.sh
```
Then, execute `source ~/.bashrc`.

# License
FreeBSD License

