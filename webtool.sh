#!/bin/sh

# webtool init
if [ "$1" == "init" ]; then
    mkdir .webtool || exit 1
    touch .webtool/config || exit 1
    exit 0
fi

# Current directory

export currentdir="`pwd`"

# Find configuration
while [ ! -d .webtool -a "`pwd`" != '/' ]; do
    cd ..
done

if [ ! -d .webtool ]; then
    echo "Not in a webtool tree. Use 'webtool init' to start a webtool tree." >&2
    exit 1;
fi

webtooldir="/home/pavlix/src/webtool"
sourcedir="`pwd`"

. .webtool/config

# local directories
export webtooldir="`readlink -f "$webtooldir"`"
export sourcedir="`readlink -f "$sourcedir"`"
export builddir="`readlink -f "$builddir"`"
export destdir="`readlink -f "$destdir"`"
# ssh directories
export syncdir="$syncdir"

if [ ! "$builddir" ]; then
    echo "Build directory not sent (builddir variable)." >&2
    exit 1
fi

# no argument
if [ "$#" == 0 ]; then
    echo "Usage: webtool <command> ..." >&2
    echo >&2 
    echo "Commands:" >&2 
    ( cd "$webtooldir/commands"; ls | sed -e 's/^/  /' -e 's/\.sh$//g' >&2 )
    exit 1
fi

command="$1"; shift

sh "$webtooldir/commands/$command.sh" "$@"
