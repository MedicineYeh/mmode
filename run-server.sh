#!/bin/bash
if [[ "$1" == "" ]] ; then
        echo "Please give IP with its mask"
        echo "Usage: $0 {IP}/{MASK}"
        echo "Example: $0 127.0.0.1/24"
        exit 0
fi

distccd --daemon --log-stderr --no-detach --allow $1

