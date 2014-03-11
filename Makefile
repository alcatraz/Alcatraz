ARCHIVE            = "Alcatraz.tar.gz"
BUNDLE_NAME        = "Alcatraz.xcplugin"
VERSION_LOCATION   = "Alcatraz/ATZVersion.h"
INSTALL_PATH       = "~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/${BUNDLE_NAME}/"
DEFAULT_BUILD_ARGS = -workspace TestProject/TestProject.xcworkspace -scheme TestProject
XCODEBUILD         = xcodebuild $(DEFAULT_BUILD_ARGS)
VERSION            = $(shell grep 'ATZ_VERSION' Alcatraz/ATZVersion.h | cut -d " " -f 3 | tr -d '"')

default: test

ci: clean ci_test

shipit: version build github_release push_deploy_branch

clean:
	$(XCODEBUILD) clean | xcpretty -c
	rm -rf build

# Run tests
ci_test:
	set -o pipefail && $(XCODEBUILD) test | xcpretty -c

test:
	set -o pipefail && $(XCODEBUILD) test | tee xcodebuild.log | xcpretty -tc

# Merge changes into deploy branch
push_deploy_branch:
	git fetch origin
ifeq ($(shell git diff origin/master..master),)
	git checkout deploy
	git reset --hard origin/master
	git push origin deploy
	git checkout -
else
	$(error you have unpushed commits on the master branch)
endif

# Build archive ready for distribution
build: clean
	xcodebuild -project Alcatraz.xcodeproj build
	rm -rf ${BUNDLE_NAME}
	cp -r ${INSTALL_PATH} ${BUNDLE_NAME}
	mkdir -p releases/${VERSION}
	tar -czf releases/${VERSION}/${ARCHIVE} ${BUNDLE_NAME}
	rm -rf ${BUNDLE_NAME}

# Download and install latest build
install:
	rm -rf $INSTALL_PATH
	curl $URL | tar xv -C ${BUNDLE_NAME} -

# Create a Github release
github_release:
	git push
	git push --tags
	gh release create -d -m "Release ${VERSION}" ${VERSION}

# Set latest version
# Requires VERSION argument set
version:
	git add $(VERSION_LOCATION)
	git commit -m "Bump version $(VERSION)"
	git tag $(VERSION)

