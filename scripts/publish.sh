#!/bin/bash

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p $SRCROOT/output

for dir in $SRCROOT/charts/*;
do
 echo "Processing $dir"
 version=$(cat $dir/Chart.yaml | grep version: | awk '{print $2}')
 tar -cvzf $SRCROOT/output/$(basename $dir)-$version.tgz -C $dir .
 cd $SRCROOT/output && helm repo index .
done
