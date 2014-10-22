#!/bin/bash

configure() {
  ADB_PATH=adb
  GIT_CMD=`git describe --tags --dirty`
  APP_NAME=$(cat app/src/main/res/values/strings.xml | grep app_name | perl -lne 'if(/>[^<]*</){$_=~m/>([^<]*)</;push(@a,$1)}if(eof){foreach(@a){print $_}}')
  APK_DEBUG_SRC=app/build/outputs/apk/app-debug-unaligned.apk
  APK_RELEASE_SRC=app/build/outputs/apk/app-release-unsigned.apk
  BUILDS_DIR=$HOME/builds
  DEBUG_DIR=$BUILDS_DIR/debug
  RELEASE_DIR=$BUILDS_DIR/release
  APK_NAME=$APP_NAME-"$GIT_CMD"
  APK_DEBUG_DIR=$DEBUG_DIR/$APK_NAME
  APK_RELEASE_DIR=$RELEASE_DIR/$APK_NAME
  APK_DEBUG_DST=$APK_DEBUG_DIR/$APK_NAME.apk
  APK_RELEASE_DST=$APK_RELEASE_DIR/$APP_NAME.apk
  KEYPATH=$HOME/Documents/profsys/IKK.signing.keystore
  ALIAS=profsys

  if [ ! -d "./app" ]; then
    echo Could not find app directory in `pwd`.
    echo Please run this script where the app directory is available.
    exit
  fi

  if [[ $GIT_CMD == *dirty* ]]
  then
    echo "error: build or release not allowed with dirty changes!";
    exit
  fi
}

pre_install() {
  if [ ! -f $APK_DEBUG_DST ]; then
    echo Could not find $APK_DEBUG_DST.
    echo Running build.
    clean
    build
  fi
}

install_apk() {
  $ADB_PATH install $APK_DEBUG_DST
}

build() {
  ./gradlew assemble

  mkdir -p $APK_DEBUG_DIR
  zipalign -f 4 $APK_DEBUG_SRC $APK_DEBUG_DST
}

release() {
  ./gradlew assembleRelease
  mkdir -p $APK_RELEASE_DIR

  cp $APK_RELEASE_SRC $APK_RELEASE_DST

  jarsigner -verbose -sigalg MD5withRSA -digestalg SHA1 -keystore $KEYPATH $APK_RELEASE_DST $ALIAS
}

print_usage() {
  echo "Please add an argument!"
  echo "build or release"
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

  if [[ "$1" == "build" ]]
  then
    build
  elif [[ "$1" == "release" ]]
  then
    release
  else
    echo Nothing todo for $1
  fi
}

main $1
