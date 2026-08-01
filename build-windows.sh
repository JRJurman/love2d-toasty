cd windows && cat love.exe ../toasty.love > Toasty.exe
rm -f ../Toasty-Windows.zip
zip -j ../Toasty-Windows.zip SDL2.dll OpenAL32.dll Toasty.exe license.txt love.dll lua51.dll mpg123.dll msvcp120.dll msvcr120.dll ../sral/SRAL.dll
