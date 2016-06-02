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
static NSString *const INSTALLED_IDEPLUGINS_RELATIVE_PATH = @"Library/Developer/Xcode/Plug-ins";
static NSString *const DOWNLOADED_PLUGINS_RELATIVE_PATH = @"Plug-ins";

static NSString *const XCODE_BUILD = @"/usr/bin/xcodebuild";
static NSString *const PROJECT = @"-project";
static NSString *const CLEAN = @"clean";
static NSString *const BUILD = @"build";
static NSString *const XCODEPROJ = @"xcodeproj";
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
    NSString *pluginInstallName = [self installNameFromPbxproj:package] ?: [package.name stringByAppendingString:package.extension];
    NSString *pluginsInstallPath = [self pathForPluginsWithExtension:[pluginInstallName pathExtension]];

    return [pluginsInstallPath stringByAppendingPathComponent:pluginInstallName];
}

- (NSString *)pathForPluginsWithExtension:(NSString *)extension
{
    NSString *path;

    if ([extension isEqualToString:@"ideplugin"]) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_IDEPLUGINS_RELATIVE_PATH];
    } else {
        path = [NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_PLUGINS_RELATIVE_PATH];
    }

    return path;
}

#pragma mark - Hooks
// Note: this is an early alpha implementation. It needs some love
- (void)reloadXcodeForPackage:(ATZPackage *)plugin completion:(void(^)(NSError *))completion {

    NSBundle *pluginBundle = [NSBundle bundleWithPath:[self pathForInstalledPackage:plugin]];
    NSLog(@"Trying to reload plugin: %@ with bundle: %@", plugin.name, pluginBundle);

    if (!pluginBundle) {
        NSString *description = [NSString stringWithFormat:@"Bundle for %@ was not found", plugin.name];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description };
        completion([NSError errorWithDomain:ATZInstallerErrorDomain code:ATZInstallerBundleNotFoundError userInfo:userInfo]);
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
    NSError *xcodeProjError;
    NSString *xcodeProjPath = [self findXcodeprojPathForPackage:plugin error:&xcodeProjError];
    if (!xcodeProjPath) {
        completion(xcodeProjError);
        return;
    }

    ATZShell *shell = [ATZShell new];
    [shell executeCommand:XCODE_BUILD withArguments:@[CLEAN, BUILD, PROJECT, xcodeProjPath]
               completion:^(NSString *output, NSError *error) {
        NSLog(@"Xcodebuild output: %@", output);
        completion(error);
    }];
}

- (NSString *)findXcodeprojPathForPackage:(ATZPackage *)package error:(NSError **)error {
    NSString *clonedDirectory = [self pathForDownloadedPackage:package];
    NSString *xcodeProjFilename = [package.name stringByAppendingPathExtension:XCODEPROJ];
    NSMutableArray *allXcodeProjFilenames = [NSMutableArray new];

    NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonedDirectory];
    for (NSString *directoryEntry in enumerator)
    {
        NSString *fileName = directoryEntry.pathComponents.lastObject;
        if ([fileName isEqualToString:xcodeProjFilename]) {
            return [clonedDirectory stringByAppendingPathComponent:directoryEntry];
        } else if ([fileName.pathExtension isEqualToString:XCODEPROJ]) {
            [allXcodeProjFilenames addObject:directoryEntry];
        }
    }

    if (allXcodeProjFilenames.count == 1) {
        return [clonedDirectory stringByAppendingPathComponent:allXcodeProjFilenames[0]];
    }

    if (error) {
        NSString *description = [NSString stringWithFormat:@"No .xcodeproj file was found for %@", package.name];
        NSString *recoverySuggestion;
        if (allXcodeProjFilenames.count == 0) {
            recoverySuggestion = [NSString stringWithFormat:@"No .xcodeproj file was found in \"%@\"", clonedDirectory];
        } else {
            recoverySuggestion = [NSString stringWithFormat:@"Found several .xcodeproj files in \"%@\" {%@}", clonedDirectory, [allXcodeProjFilenames componentsJoinedByString:@","]];
        }
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: description, NSLocalizedRecoverySuggestionErrorKey: recoverySuggestion };
        *error = [NSError errorWithDomain:ATZInstallerErrorDomain code:ATZInstallerXcodeProjectNotFoundError userInfo:userInfo];
    }
    return nil;
}

- (NSString *)installNameFromPbxproj:(ATZPackage *)package {
    NSString *pbxprojPath = [[self findXcodeprojPathForPackage:package error:NULL] stringByAppendingPathComponent:PROJECT_PBXPROJ];

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
