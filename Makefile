ARCHIVE="alcatraz.tar.gz"
BUNDLE_NAME="Alcatraz.xcplugin"
BUCKET="xcode-fun-time"
URL="https://s3.amazonaws.com/${BUCKET}/${ARCHIVE}"
INSTALL_PATH="~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/${BUNDLE_NAME}/"
VERSION_LOCATION="Alcatraz/Views/ATZVersionLabel.m"
VERSION_TMP_FILE="output.m"
BUILD_TOOL=xcodebuild
DEFAULT_BUILD_ARGS=-workspace Alcatraz.xcworkspace -scheme Alcatraz

default: spec

ci: spec

shipit: update build upload

clean:
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) clean
	rm -rf build

# Run tests
spec: clean
	$(BUILD_TOOL) $(DEFAULT_BUILD_ARGS) test; echo "status: $?"; tail xcodebuild.log

# Merge changes into deploy branch
update:
	git fetch origin
ifeq ($(shell git diff origin/master..master),)
	git checkout deploy
	git reset --hard origin/master
	git push origin deploy
else
	$(error you have unpushed commits on the master branch)
endif

# Build archive ready for distribution
build: clean
	$(BUILD_TOOL) -project Alcatraz.xcodeproj build
	rm -rf ${BUNDLE_NAME}
	cp -r ${INSTALL_PATH} ${BUNDLE_NAME}
	tar -czf ${ARCHIVE} ${BUNDLE_NAME}
	rm -rf ${BUNDLE_NAME}

# Download and install latest build
install:
	rm -rf $INSTALL_PATH
	curl $URL | tar xv -C ${BUNDLE_NAME} -

# Upload build to S3
upload:
	ruby scripts/upload_build.rb ${ARCHIVE} ${BUCKET}

# Set latest version
# Requires VERSION argument set
version:
ifdef VERSION
	git checkout master
	sed 's/ATZ_VERSION "[0-9]\{1,3\}.[0-9]\{1,3\}"/ATZ_VERSION "${VERSION}"/g' ${VERSION_LOCATION} > ${VERSION_TMP_FILE}
	sed 's/ATZ_REVISION "[0-f]\{7\}"/ATZ_REVISION "$(shell git log --pretty=format:'%h' -n 1)"/g' ${VERSION_TMP_FILE} > ${VERSION_LOCATION}
	rm ${VERSION_TMP_FILE}
	git add ${VERSION_LOCATION}
	git commit -m "Release ${VERSION}"
	git tag ${VERSION}
else
	$(error VERSION has not been set)
endif

