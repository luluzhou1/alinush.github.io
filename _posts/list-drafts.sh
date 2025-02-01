#!/bin/bash

scriptdir=$(cd $(dirname $(readlink -f $0)); pwd -P)

(
    cd $scriptdir/
    grep '^published: false' *.md | cut -f1 -d:
)
