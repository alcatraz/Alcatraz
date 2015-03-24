#!/bin/sh

DOWNLOAD_URI=https://github.com/supermarin/Alcatraz/releases/download/1.1/Alcatraz.tar.gz
PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"

mkdir -p "${PLUGINS_DIR}"
curl -L $DOWNLOAD_URI | tar xvz -C "${PLUGINS_DIR}"

echo "Alcatraz successfuly installed!!!!🍻   Please restart your Xcode."

