#!/bin/bash

set -e

scriptdir=$(cd $(dirname $0); pwd -P)

vim $scriptdir/_data/navigation.yml
echo
echo $scriptdir/_data/navigation.yml
echo
