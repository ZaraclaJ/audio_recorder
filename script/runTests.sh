#!/usr/bin/env bash

# runs tests in a flutter package
runTests () {
  cd $1
  echo "running tests in $1"
  rm -rf "coverage"
  flutter test --coverage
  if [ -d "coverage" ]; then
    # combine line coverage info from package tests to a common file
    if [ "$1" == "." ]; then
      cat coverage/lcov.info >> $2/lcov.info
    else
      escapedPath="$(echo ${1:2} | sed 's/\//\\\//g')"
      sed "s/^SF:lib/SF:$escapedPath\/lib/g" coverage/lcov.info >> $2/lcov.info
    fi
  fi
}

# if running locally
rm -f lcov.info

runTests "." `pwd`
runTests "./example" `pwd`
