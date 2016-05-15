#!/bin/bash

export MY_DEPS_PATH=/var/go/deps
source ~/.kerl/installs/18.2.1/activate
export PATH=`pwd`/vendor/elixir/bin:$PATH

mix do deps.compile, compile
VERSION=$( mix version )
echo "Version:" $VERSION

COMMIT_TAG=$(git describe --exact-match HEAD)
if [ $? == 0 ] && [$COMMIT_TAG == $VERSION]
then
  echo "Build release:" $VERSION
  mix edeliver build release
else
  echo "Not a release build"
fi
