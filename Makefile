ARCHIVE            = "Alcatraz.tar.gz"
BUNDLE_NAME        = "Alcatraz.xcplugin"
VERSION_LOCATION   = "Alcatraz/ATZVersion.h"
INSTALL_PATH       = ~/Library/Application\ Support/Developer/Shared/Xcode/Plug-ins/${BUNDLE_NAME}/
TEST_BUILD_ARGS	   = -workspace TestProject/TestProject.xcworkspace -scheme TestProject
XCODEBUILD         = xcodebuild $(TEST_BUILD_ARGS)
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
	xcodebuild -project Alcatraz.xcodeproj build | tee xcodebuild.log | xcpretty -c
	rm -rf ${BUNDLE_NAME}
	cp -r ${INSTALL_PATH} ${BUNDLE_NAME}
	mkdir -p releases/${VERSION}
	tar -czf releases/${VERSION}/${ARCHIVE} ${BUNDLE_NAME}
	rm -rf ${BUNDLE_NAME}

# Create a Github release
github_release:
	git push -u origin master
	git push --tags
	gh release create -m "Release ${VERSION}" ${VERSION}

# Commit & tag the version from ATZVersion.h
version: update_install_url
	- git tag $(VERSION)

update_install_url:
	sed -i '' -e 's/[.0-9]\{3,5\}/${VERSION}/' Scripts/install.sh

