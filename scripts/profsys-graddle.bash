#!/bin/bash

configure() {
  if [[ "$ADB_PATH" == "" ]]; then
    echo "Searching for adb"
    ADB_PATH=`find / -name adb`
  fi
  APP_NAME="$(cat app/src/main/res/values/strings.xml | grep app_name | perl -lne 'if(/>[^<]*</){$_=~m/>([^<]*)</;push(@a,$1)}if(eof){foreach(@a){print $_}}')"
  OUTPUT_DIR=app/build/outputs
  LINT_RESULTS=$OUTPUT_DIR/*.html
  APK_DEBUG_SRC=$OUTPUT_DIR/apk/app-staging-debug-unaligned.apk
  APK_PRODUCTION_SRC=$OUTPUT_DIR/apk/app-production-release-unsigned.apk
  BUILDS_DIR=$HOME/Dropbox/builds
  DEBUG_DIR=$BUILDS_DIR/debug
  PRODUCTION_DIR=$BUILDS_DIR/production
  APK_NAME="$APP_NAME"-"$GIT_CMD"
  APK_DEBUG_DIR="$DEBUG_DIR/$APK_NAME"
  APK_PRODUCTION_DIR="$PRODUCTION_DIR/$APK_NAME"
  APK_DEBUG_DST=$APK_DEBUG_DIR/$APK_NAME.apk
  APK_PRODUCTION_DST=$APK_PRODUCTION_DIR/"$APP_NAME".apk
  if [[ "$KEYPATH" == "" ]]; then
    echo "Searching for keypath"
    KEYPATH=$HOME/Documents/profsys/"$APP_NAME".signing.keystore
  fi
  ALIAS=profsys
  if [[ "$ZIP_ALIGN_PATH" == "" ]]; then
    echo "Searching for zipalign"
    ZIP_ALIGN_PATH=`find / -name zipalign|tail -n1`
  fi

  if [ ! -d "./app" ]; then
    echo Could not find app directory in `pwd`.
    echo Please run this script where the app directory is available.
    exit
  fi

  if [[ $GIT_CMD == *dirty* ]]
  then
    echo "error: staging or release not allowed with dirty changes!";
    exit
  fi

  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  if $DIR/easytracker-check.sh | grep MISSING; then
    echo "error: some activities do not have google analytics properly enabled!";
    exit
  fi
}

pre_install() {
  if [ ! -f "$APK_DEBUG_DST" ]; then
    echo Could not find $APK_DEBUG_DST.
    echo Running staging.
    staging
  fi
}

install_apk() {
  $ADB_PATH install -r $APK_DEBUG_DST
}

staging() {
  ./gradlew assembleStaging

  mkdir -p $APK_DEBUG_DIR
  $ZIP_ALIGN_PATH -f 4 "$APK_DEBUG_SRC" "$APK_DEBUG_DST"
}

lint() {
  ./gradlew build connectedCheck
  cp $LINT_RESULTS $APK_DEBUG_DIR
}

production() {
  ./gradlew assembleRelease
  mkdir -p "$APK_PRODUCTION_DIR"

  done_file=/tmp/done.html
  echo "<h1>Need to sign</h1>" > $done_file
  open $done_file
  jarsigner -verbose -sigalg MD5withRSA -digestalg SHA1 -keystore "$KEYPATH" "$APK_PRODUCTION_SRC" $ALIAS
  $ZIP_ALIGN_PATH -f 4 "$APK_PRODUCTION_SRC" "$APK_PRODUCTION_DST"
  echo copied to "$APK_PRODUCTION_DIR"
  unamestr=`uname`
  if [[ "$unamestr" == 'Linux' ]]; then
    xdg-open "$APK_PRODUCTION_DIR"
  elif [[ "$unamestr" == 'Darwin' ]]; then
    open "$APK_PRODUCTION_DIR"
  fi

  if [ ! -d "./html/" ]; then
    return
  fi
  echo Found documentation
  cp html/* "$APK_PRODUCTION_DIR/"
}

print_usage() {
  echo "Please add an argument!"
  echo "staging or production"
}

clean() {
  ./gradlew clean
}

main() {

  if [[ "$1" == "" ]]
  then
    print_usage
    exit
  fi

  GIT_CMD=`git describe --tags --dirty`
  if [[ -z $GIT_CMD ]]
  then
    echo "Aborting"
    exit
  fi

  configure

  if [[ "$1" == "install" ]]
  then
    pre_install
    install_apk
    exit
  elif [[ "$1" == "clean" ]]
  then
    clean
    exit
  fi

  clean

  if [[ "$1" == "staging" ]]
  then
    staging
  elif [[ "$1" == "prod" ]]
  then
    production
  elif [[ "$1" == "lint" ]]
  then
    lint
  else
    echo Nothing todo for $1
  fi
}

main $1
