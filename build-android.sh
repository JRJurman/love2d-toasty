#!/usr/bin/env bash
cd android
case "$1" in
  --apk) ./gradlew assembleEmbedNoRecordRelease && cp app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release.apk ../Toasty-Android.apk ;;
  --aab) ./gradlew bundleEmbedNoRecordRelease && cp app/build/outputs/bundle/embedNoRecordRelease/app-embed-noRecord-release.aab ../Toasty-Android.aab ;;
  --device) ./gradlew installEmbedNoRecordDebug ;;
  *) echo 'provide target'
esac
