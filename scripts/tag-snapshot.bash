#!/bin/bash

# Script to ease creating testing tags.  Some of the variables are copied of a
# thread on [swift-dev][0] titled buildbot configuration + etc
# The read call is copied from stackoverflow[1]
#[0]: https://lists.swift.org/mailman/listinfo/swift-dev
#[1]: http://stackoverflow.com/questions/1885525/how-do-i-prompt-a-user-for-confirmation-in-bash-script

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
DAY=$(date +"%d")
VERSION="${YEAR}-${MONTH}-${DAY}"


read -p "Want me to tag HEAD to $VERSION?" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
  git tag "$VERSION"
fi

read -p "Want me to push it to origin?" -n 1 -r
echo    
if [[ $REPLY =~ ^[Yy]$ ]]
then
  git push origin "$VERSION"
fi
