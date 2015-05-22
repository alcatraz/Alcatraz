// PluginInstaller.m
//
// Copyright (c) 2013 Marin Usalj | supermar.in
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "ATZPluginInstaller.h"
#import "ATZPlugin.h"
#import "ATZShell.h"
#import "ATZGit.h"
#import "ATZPBXProjParser.h"

static NSString *const INSTALLED_PLUGINS_RELATIVE_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins";
static NSString *const DOWNLOADED_PLUGINS_RELATIVE_PATH = @"Plug-ins";

static NSString *const XCODE_BUILD = @"/usr/bin/xcodebuild";
static NSString *const PROJECT = @"-project";
static NSString *const CLEAN = @"clean";
static NSString *const BUILD = @"build";
static NSString *const XCODEPROJ = @".xcodeproj";
static NSString *const PROJECT_PBXPROJ = @"project.pbxproj";

@implementation ATZPluginInstaller

#pragma mark - Abstract

- (void)downloadPackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {
    [[NSFileManager sharedManager] removeItemAtPath:[self pathForDownloadedPackage:package] error:NULL];
    [ATZGit cloneRepository:package.remotePath toLocalPath:[self pathForDownloadedPackage:package]
                 completion:completion];
}

- (void)updatePackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {

    [ATZGit updateRepository:[self pathForDownloadedPackage:package] revision:package.revision
                  completion:completion];
}


- (void)installPackage:(ATZPlugin *)package completion:(void(^)(NSError *))completion {
    [self buildPlugin:package completion:completion];
}

- (NSString *)downloadRelativePath {
    return DOWNLOADED_PLUGINS_RELATIVE_PATH;
}

// This is a temporary support for installs in /tmp.
- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    NSString *pluginsInstallPath = [NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_PLUGINS_RELATIVE_PATH];
    NSString *pluginInstallName = [self installNameFromPbxproj:package] ?: package.name;

    return [[pluginsInstallPath stringByAppendingPathComponent:pluginInstallName]
                                       stringByAppendingString:package.extension];
}


#pragma mark - Hooks
// Note: this is an early alpha implementation. It needs some love
- (void)reloadXcodeForPackage:(ATZPackage *)plugin completion:(void(^)(NSError *))completion {

    NSBundle *pluginBundle = [NSBundle bundleWithPath:[self pathForInstalledPackage:plugin]];
    NSLog(@"Trying to reload plugin: %@ with bundle: %@", plugin.name, pluginBundle);

    if (!pluginBundle) {
        completion([NSError errorWithDomain:@"Bundle was not found" code:669 userInfo:nil]);
        return;
    }
    else if ([pluginBundle isLoaded]) {
        completion(nil);
        return;
    }

    NSError *loadError = nil;
    BOOL loaded = [pluginBundle loadAndReturnError:&loadError];
    if (!loaded)
        NSLog(@"[Alcatraz] Plugin load error: %@", loadError);

    [self reloadPluginBundleWithoutWarnings:pluginBundle forPlugin:plugin];

    completion(nil);
}

#pragma mark - Private

- (void)buildPlugin:(ATZPlugin *)plugin completion:(void (^)(NSError *))completion {

    NSString *xcodeProjPath;

    @try { xcodeProjPath = [self findXcodeprojPathForPlugin:plugin]; }
    @catch (NSException *exception) {
        completion([NSError errorWithDomain:exception.reason code:666 userInfo:nil]);
        return;
    }

    ATZShell *shell = [ATZShell new];
    [shell executeCommand:XCODE_BUILD withArguments:@[CLEAN, BUILD, PROJECT, xcodeProjPath]
               completion:^(NSString *output, NSError *error) {
        NSLog(@"Xcodebuild output: %@", output);
        completion(error);
    }];
}

- (NSString *)findXcodeprojPathForPlugin:(ATZPlugin *)plugin {
    NSString *clonedDirectory = [self pathForDownloadedPackage:plugin];
    NSString *xcodeProjFilename = [plugin.name stringByAppendingString:XCODEPROJ];

    NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonedDirectory];
    NSString *directoryEntry;

    while (directoryEntry = [enumerator nextObject])
        if ([directoryEntry.pathComponents.lastObject isEqualToString:xcodeProjFilename])
            return [clonedDirectory stringByAppendingPathComponent:directoryEntry];

    NSLog(@"Wasn't able to find: %@ in %@", xcodeProjFilename, clonedDirectory);
    @throw [NSException exceptionWithName:@"Not found" reason:@".xcodeproj was not found" userInfo:nil];
}

- (NSString *)installNameFromPbxproj:(ATZPackage *)package {
    NSString *pbxprojPath = [[[[self pathForDownloadedPackage:package]
                               stringByAppendingPathComponent:package.name] stringByAppendingString:XCODEPROJ]
                             stringByAppendingPathComponent:PROJECT_PBXPROJ];

    return [ATZPbxprojParser xcpluginNameFromPbxproj:pbxprojPath];
}

- (void)reloadPluginBundleWithoutWarnings:(NSBundle *)pluginBundle forPlugin:(ATZPackage *)plugin {
    Class principalClass = [pluginBundle principalClass];
    if ([principalClass respondsToSelector:NSSelectorFromString(@"pluginDidLoad:")]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [principalClass performSelector:NSSelectorFromString(@"pluginDidLoad:") withObject:pluginBundle];
#pragma clang diagnostic pop

    } else {
        NSLog(@"%@",[NSString stringWithFormat:@"%@ does not implement the pluginDidLoad: method.", plugin.name]);
    }
}

@end
