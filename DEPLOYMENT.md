# Deployment

Here are the steps for deploying the latest version of the project

1. Run `./build.sh` to create the love2d export (required before all other steps)
2. Run `./build-android.sh --apk` to create the android apk
3. Run `./build-webexport.sh` to create the WebExport.zip
4. In Xcode, select the love project, change the target to "Any iOS device", and then select Product > Archive. (Note, change the version or build number before deployment)
