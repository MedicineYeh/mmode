# Introduction
__mmode__ is a tool to enable super fast compilation ability in an easy way.
This framework automatically set configurations of __distcc__ to achieve better performance out of box then using __distcc__ directly.
It supports `ccache`, `distcc` and `ccache+distcc` modes.

Ccache is __compiler cache__ to accelerate the speed of compilation by caching the compiled data. Recompile linux kernel in less than 5s!!!

Distcc is __distributed cc__. It's a stateless distributed compilation framework. With about 2 Xeon servers(24 threads), distcc reduces about 60% of time on compiling Linux kernel.

__mmode__ supports both `bash` and `zsh` shells!!

[![Build Status](https://travis-ci.org/MedicineYeh/mmode.svg?branch=master)](https://travis-ci.org/MedicineYeh/mmode)

## Why Should I Use This?
1. This framework automatically set proper parameter of __distcc__ to achieve better performance out of box then using __distcc__ directly.
2. This framework provides both server side container with multiple gcc version for your needs. :D
3. This framework automatically set the correct configurations for you.
4. No need to type long command. All you need to type is `mmode distcc`!
5. It's FreeBSD License!!

## Attention!
If you are using the DockerFile and `mmode` this repository provided and your Linux is not using latest gcc, ex: Ubuntu users, please enable the auto-version-detection in the `mmode.sh`.
See more information: [Automatically gcc version detection](#automatically-gcc-version-detection).

# Usage
* `mmode distcc`: Set to distcc compiling mode
* `mmode ccache`: Set to ccache compiling mode
* `mmode both`: Set both modes simultaneously
* `mmode reset`: Reset to normal mode
Execute `mmode --help` to see more information of the commands.

After changing the mode, you can simply execute `make` to compile your projects without __-j__.
__mmode__ automatically choose the optimal number for your compilation.
If you want to override the number of parallel compilation, execute `make -jN` instead, where N is the number you specify.

# Prerequests
* [distcc](https://github.com/distcc/distcc)
* [ccache](https://ccache.samba.org/)

Normally, you can install them by your package manager.

# Settings
## distcc
You have to specify `DISTCC_HOSTS` in the script in order to connect distcc server.
You can also use `DISTCC_HOSTS` environment variable to specify the distcc servers.
Here is an example:
`export DISTCC_HOSTS='1.1.1.1/8,lzo sample.server.url/12,lzo localhost/2'`
* __1.1.1.1/8,lzo__: 1.1.1.1 is the IP address of distcc server. 8 is the number of cores provided by that server. lzo is using __lzo__ compression algorithm on the file before sending it.
* __sample.server.url/12,lzo__: "sample.server.url" is the URL of distcc server. 12 is the number of cores provided by that server. lzo is using __lzo__ compression algorithm on the file before sending it.
* __localhost/2__: means locally provide 2 cores for compilation. lzo is not needed since it's localhost.

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

## Automatically gcc version detection
Set `M_AUTO_VERSION_DETECTION` to __y__ if you use the docker image.
This could be very useful when your default compiler is not the same as the server's default compiler.

To make your distcc server more general/compatible for different clients, you can run the docker image mentioned below.

# Docker Image
Distcc does not work properly when the compiler versions of the client and servers did not match.
When you enable this feature, the script will detect your gcc version and add suffix on calling gcc.
Distcc will then dispatch post-processing job to remote server and call the __specific__ version of gcc to compile.
Thus, I build a docker image containing multiple gcc versions for setting up distcc server easily.

There is a Dockerfile in this repo to download docker image and install newest gcc.
The original gcc version in this docker image is __gcc-5.3__.
If you don't want to install the newest gcc, simply remove the `RUN pacman -Sy` line in `Dockerfile`.

On your server, in the mmode repository folder, simply run two commands to build and host a distcc server.
``` bash
sudo docker build -t distcc_server .
sudo docker run --rm -t -i -p 3632:3632 distcc_server 127.0.0.1/24
```
* `127.0.0.1/24` should be set to a IP range you want to allow a connection.
* `3632:3632` is the port forwarding(HOST:CONTAINER). The default port is 3632. Normally you don't need to change the port number.

# Installation
## Your computer
* Copy mmode.sh to `~/.mmode.sh` by `cp ./mmode.sh ~/.mmode.sh`
* Add the following lines to your `~/.bashrc`, `~/.bash_profile`, etc.
``` bash
source ~/.mmode.sh
```
* If you want to specify servers by env vars add export before the `source ~/.mmode.sh`
``` bash
export DISTCC_HOSTS='localhost/2'
source ~/.mmode.sh
```
* Enable/disable features in the script `~/.mmode.sh`
* Then, execute `source ~/.bashrc` (Your shell config file).

## Distcc Server
1. Install distcc by package manager or compile it by your own.
2. Run `distccd --daemon --log-stderr --no-detach --allow 127.0.0.1/24`. __127.0.0.1/24__ is the address range you want to allow for connection.

Alternatively, follow the steps listed in __Docker Image__ above.

# License
FreeBSD License


