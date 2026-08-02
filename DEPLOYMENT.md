# Deployment

Here are the steps for deploying the latest version of the project

1. Run `./build.sh` to create the love2d export (required before all other steps)
2. Run `./build-android.sh --apk` to create the android apk
3. Run `./build-webexport.sh` to create the Web Build
4. In Xcode, select the love project, change the target to "Any iOS device", and then select Product > Archive. (Note, change the version or build number before deployment)
5. Run `./build-windows.sh` to create the Windows build
6. Run `./build-linux.sh` to create the linux build
