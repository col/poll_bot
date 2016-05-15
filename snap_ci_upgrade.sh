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
  DEPLOYED_VERSION=$( curl -s http://bothub.colharris.com/bots/PollBot/version )
  echo "Deployed Version:" $DEPLOYED_VERSION

  echo "Build upgrade from $DEPLOYED_VERSION to $VERSION"
  mix edeliver build upgrade --with=$DEPLOYED_VERSION --to=$VERSION
  mix edeliver deploy upgrade to production
else
  echo "Not a release build"
fi
