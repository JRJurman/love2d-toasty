# after starting the game on a connected android device
adb logcat --pid=$(adb shell pidof -s com.jrjurman.toasty)
