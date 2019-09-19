#!/bin/bash

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"
GIT_PUSH=${GIT_PUSH:-true}

rm -rf $SRCROOT/output && git clone -b gh-pages git@github.com:argoproj/argo-helm.git $SRCROOT/output

for dir in $SRCROOT/charts/*;
do
 echo "Processing $dir"
 version=$(cat $dir/Chart.yaml | grep version: | awk '{print $2}')
 tar -cvzf $SRCROOT/output/$(basename $dir)-$version.tgz -C $dir .
 cd $SRCROOT/output && helm repo index .
done

cd $SRCROOT/output && git status

if [ "$GIT_PUSH" == "true" ]
then
    cd $SRCROOT/output && git add . && git commit -m "Publish charts" && git push git@github.com:argoproj/argo-helm.git gh-pages
fi
