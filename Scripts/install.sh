#!/bin/sh

set -euo pipefail

DOWNLOAD_URI=https://github.com/alcatraz/Alcatraz/releases/download/1.1.15/Alcatraz.tar.gz
PLUGINS_DIR="${HOME}/Library/Application Support/Developer/Shared/Xcode/Plug-ins"
XCODE_VERSION="$(xcrun xcodebuild -version | head -n1 | awk '{ print $2 }')"
PLIST_PLUGINS_KEY="DVTPlugInManagerNonApplePlugIns-Xcode-${XCODE_VERSION}"
BUNDLE_ID="com.mneorr.Alcatraz"
TMP_FILE="$(mktemp -t ${BUNDLE_ID})"

# Remove Alcatraz from Xcode's skipped plugins list if needed
defaults read -app Xcode "$PLIST_PLUGINS_KEY" > "$TMP_FILE" && {
    /usr/libexec/PlistBuddy -c "delete skipped:$BUNDLE_ID" "$TMP_FILE" > /dev/null 2>&1 && {
	pgrep Xcode > /dev/null && {
            echo 'An instance of Xcode is currently running.' \
		 'Please close Xcode before installing Alcatraz.'
            exit 1
	}
	defaults write -app Xcode "$PLIST_PLUGINS_KEY" "$(cat "$TMP_FILE")"
	echo 'Alcatraz was removed from Xcode'\''s skipped plugins list.' \
             'Next time you start Xcode select "Load Bundle" when prompted.'
    }
}
rm -f "$TMP_FILE"

mkdir -p "${PLUGINS_DIR}"
curl -L $DOWNLOAD_URI | tar xvz -C "${PLUGINS_DIR}"

# the 1 is not a typo!
echo 'Alcatraz successfully installed!!1!🍻 ' \
     "Please restart your Xcode ($XCODE_VERSION)."

