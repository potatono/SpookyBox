#!/bin/sh
rm -rf spookybox/bin
rm -rf spookybox/src
cp -R bin spookybox
cp -R src spookybox
cd spookybox/bin
zip -r ../library/spookybox.jar *
cd ../..
rm -rf ~/Documents/Processing/libraries/spookybox
mkdir ~/Documents/Processing/libraries/spookybox
cp -R spookybox/ ~/Documents/Processing/libraries/spookybox

