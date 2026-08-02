# NOTE, we extract the AppImage into ./linux already
cd linux && cat bin/love ../toasty.love > bin/Toasty
chmod +x bin/Toasty

cp ../sral/libSRAL.so bin/

printf '#!/bin/sh\nHERE="$(dirname "$(readlink -f "$0")")"\nexec "$HERE/bin/Toasty" "$@"\n' > Toasty.sh
chmod +x Toasty.sh

tar --no-xattrs -czf ../Toasty-Linux.tar.gz bin/Toasty bin/libSRAL.so lib/* license.txt Toasty.sh
