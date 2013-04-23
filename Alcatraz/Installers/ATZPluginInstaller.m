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

static NSString *const LOCAL_PLUGINS_RELATIVE_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins";
static NSString *const XCODE_BUILD = @"/usr/bin/xcodebuild";
static NSString *const PROJECT = @"-project";
static NSString *const XCODEPROJ = @".xcodeproj";
static NSString *const XCPLUGIN = @".xcplugin";

@implementation ATZPluginInstaller

#pragma mark - Public

- (void)installPackage:(ATZPlugin *)plugin progress:(void (^)(NSString *))progress
            completion:(void (^)(NSError *))completion {

    [self clonePlugin:plugin progress:progress completion:^(NSError *error) {
        if (error)
            completion(error);
        else
            [self buildPlugin:plugin progress:progress completion:completion];
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
    return [[[NSHomeDirectory() stringByAppendingPathComponent:LOCAL_PLUGINS_RELATIVE_PATH]
                                stringByAppendingPathComponent:package.name]
                                       stringByAppendingString:XCPLUGIN];
}

- (void)clonePlugin:(ATZPlugin *)plugin progress:(void(^)(NSString *progressMesssage))progress completion:(void (^)(NSError *error))completion  {

    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, plugin.name]);
    
    [ATZGit updateOrCloneRepository:plugin.remotePath
                        toLocalPath:[self pathForClonedPlugin:plugin]];
    completion(nil);
}

- (NSString *)pathForClonedPlugin:(ATZPlugin *)plugin {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:plugin.name];
}

- (void)buildPlugin:(ATZPlugin *)plugin progress:(void(^)(NSString *progressMesssage))progress completion:(void (^)(NSError *error))completion {
    ATZShell *shell = [ATZShell new];
    
    progress([NSString stringWithFormat:INSTALLING_FORMAT, plugin.name]);
    [shell executeCommand:XCODE_BUILD
            withArguments:@[PROJECT, [self findXcodeprojPathForPlugin:plugin]]
               completion:^(NSString *output) {

        completion(nil);
        [shell release];
    }];
}

- (NSString *)findXcodeprojPathForPlugin:(ATZPlugin *)plugin {
    @autoreleasepool {
        @try {
            return [self findProjectFileInDirectory:[self pathForClonedPlugin:plugin]];
        }
        @catch (NSException *exception) { NSLog(@"Exception with finding xcodeproj path! %@", exception); }
    }
}

- (NSString *)findProjectFileInDirectory:(NSString *)path {
    NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:path];
    NSString *directoryEntry;
    
    while (directoryEntry = [enumerator nextObject])
        if ([directoryEntry hasSuffix:XCODEPROJ])
            return [[path stringByAppendingPathComponent:directoryEntry] retain];
    
    @throw [NSException exceptionWithName:@"Not found" reason:@".xcodeproj was not found" userInfo:nil];
}

@end
