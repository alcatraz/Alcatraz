// PluginInstaller.m
//
// Copyright (c) 2013 Marin Usalj | mneorr.com
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

static NSString *const LOCAL_PLUGINS_RELATIVE_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins";
static NSString *const XCODE_BUILD = @"/usr/bin/xcodebuild";
static NSString *const PROJECT = @"-project";
static NSString *const XCODEPROJ = @".xcodeproj";
static NSString *const XCPLUGIN = @".xcplugin";
static NSString *const PROJECT_PBXPROJ = @"project.pbxproj";


@implementation ATZPluginInstaller

#pragma mark - Public

- (void)installPackage:(ATZPlugin *)plugin progress:(void (^)(NSString *))progress
            completion:(void (^)(NSError *))completion {
    
    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, plugin.name]);
    
    [self clonePlugin:plugin completion:^(NSError *error) {
        
        if (error) completion(error);
        else {
            progress([NSString stringWithFormat:INSTALLING_FORMAT, plugin.name]);
            [self buildPlugin:plugin completion:completion];
        }
    }];
}

- (void)removePackage:(ATZPlugin *)package
           completion:(void (^)(NSError *))completion {

    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPackage:package]
                                         completion:completion];
}

- (BOOL)isPackageInstalled:(ATZPlugin *)package {
    BOOL isDirectory;
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package] isDirectory:&isDirectory];
}


#pragma mark - Private

- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    
    NSString *pbxprojPath = [[[self pathForClonedPlugin:(id)package]
                             stringByAppendingPathComponent:XCODEPROJ] stringByAppendingPathComponent:PROJECT_PBXPROJ];
    
    return [[[NSHomeDirectory() stringByAppendingPathComponent:LOCAL_PLUGINS_RELATIVE_PATH]
                                stringByAppendingPathComponent:[ATZPbxprojParser xcpluginNameFromPbxproj:pbxprojPath] ?: package.name]
                                       stringByAppendingString:XCPLUGIN];
}

- (NSString *)pathForClonedPlugin:(ATZPlugin *)plugin {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:plugin.name];
}

- (void)clonePlugin:(ATZPlugin *)plugin completion:(void (^)(NSError *))completion  {
    
    [ATZGit updateOrCloneRepository:plugin.remotePath toLocalPath:[self pathForClonedPlugin:plugin] completion:completion];
}

- (void)buildPlugin:(ATZPlugin *)plugin completion:(void (^)(NSError *))completion {
    
    NSString *xcodeProjPath;
    @try { xcodeProjPath = [self findXcodeprojPathForPlugin:plugin]; }
    @catch (NSException *exception) {
        completion([NSError errorWithDomain:exception.reason code:666 userInfo:nil]);
        return;
    }
    
    ATZShell *shell = [ATZShell new];
    [shell executeCommand:XCODE_BUILD withArguments:@[PROJECT, xcodeProjPath] completion:^(NSString *output, NSError *error) {
        NSLog(@"Xcodebuild output: %@", output);
        if (error) {
            completion(error);
            [shell release];
            return;
        }
        
        NSString *installedPluginPath = [self pathForInstalledPackage:plugin];
        NSBundle *pluginBundle = [NSBundle bundleWithPath:installedPluginPath];
        if ([pluginBundle isLoaded]) {
            completion(nil);
            [shell release];
            return;
        }
        
        NSError *loadError = nil;
        BOOL loaded = [pluginBundle loadAndReturnError:&loadError];
        if (!loaded)
            NSLog(@"Plugin load error: %@", loadError);
        
        Class principalClass = [pluginBundle principalClass];
        if ([principalClass respondsToSelector:@selector(pluginDidLoad:)]) {
            [principalClass performSelector:@selector(pluginDidLoad:) withObject:pluginBundle];
            completion(nil);
        } else {
            NSString *errorDescription = [NSString stringWithFormat:@"The principal class of %@ does not implement the pluginDidLoad: method.", plugin.name];
            completion([NSError errorWithDomain:errorDescription code:668 userInfo:nil]);
        }
        [shell release];
    }];
}

- (NSString *)findXcodeprojPathForPlugin:(ATZPlugin *)plugin {
    NSString *clonedDirectory = [self pathForClonedPlugin:plugin];
    NSString *xcodeProjFilename = [plugin.name stringByAppendingString:XCODEPROJ];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonedDirectory];
    NSString *directoryEntry;
    
    while (directoryEntry = [enumerator nextObject])
        if ([directoryEntry.pathComponents.lastObject isEqualToString:xcodeProjFilename])
            return [clonedDirectory stringByAppendingPathComponent:directoryEntry];
    
    NSLog(@"Wasn't able to find: %@ in %@", xcodeProjFilename, clonedDirectory);
    @throw [NSException exceptionWithName:@"Not found" reason:@".xcodeproj was not found" userInfo:nil];
}

@end
