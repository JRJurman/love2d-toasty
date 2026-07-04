#!/usr/bin/env bash
cd android
case "$1" in
  --apk) ./gradlew assembleEmbedNoRecordRelease ;;
  --device) ./gradlew installEmbedNoRecordDebug ;;
  *) echo 'provide target'
esac
