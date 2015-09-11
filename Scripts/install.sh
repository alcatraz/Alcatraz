#!/bin/sh

DOWNLOAD_URI=https://github.com/supermarin/Alcatraz/releases/download/1.1.8/Alcatraz.tar.gz
PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"

mkdir -p "${PLUGINS_DIR}"
curl -L $DOWNLOAD_URI | tar xvz -C "${PLUGINS_DIR}"

# the 1 is not a typo!
echo "Alcatraz successfully installed!!1!🍻   Please restart your Xcode."

