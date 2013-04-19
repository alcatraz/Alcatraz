// PluginInstaller.m
//
// Copyright (c) 2013 mneorr.com
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


#import "PluginInstaller.h"
#import "Plugin.h"
#import "Shell.h"

static NSString *const LOCAL_PLUGINS_RELATIVE_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins";

@implementation PluginInstaller

#pragma mark - Public

- (void)installPackage:(Plugin *)plugin progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {

    [self clonePlugin:plugin
           completion:^{ [self buildPlugin:plugin completion:completion failure:failure]; }
              failure:failure];
}

- (void)removePackage:(Plugin *)package
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    NSError *error;
    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPlugin:package] error:&error];
    
    error ? failure(error) : completion();
}

- (BOOL)isPackageInstalled:(Plugin *)package {
    BOOL isDirectory;
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPlugin:package] isDirectory:&isDirectory];
}


#pragma mark - Private

- (NSString *)pathForInstalledPlugin:(Plugin *)plugin {
    return [NSString stringWithFormat:@"%@.xcplugin",
            [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), LOCAL_PLUGINS_RELATIVE_PATH, plugin.name]];
}

- (void)clonePlugin:(Plugin *)plugin completion:(void(^)(void))completion failure:(void (^)(NSError *))failure {

    NSString *output = [Shell executeCommand:[self whichGit] withArguments:@[@"clone", plugin.remotePath, plugin.name]];
    NSLog(@"Git clone returned: %@", output);
}

- (NSString *)whichGit {
    return [Shell executeCommand:@"/usr/bin/ruby" withArguments:@[@"-e 'print `which git`'"]];
}

- (NSString *)pathForClonedPlugin:(Plugin *)plugin {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:plugin.name];
}

- (void)buildPlugin:(Plugin *)plugin completion:(void(^)(void))completion failure:(void (^)(NSError *))failure {
    NSString *output = [Shell executeCommand:@"/usr/bin/xcodebuild" withArguments:@[@"-project", [self findXcodeprojPathForPlugin:plugin]]];
    // TODO: parse output, see if it failed
    NSLog(@"Xcodebuild output: %@", output);
    completion();
}


- (NSString *)findXcodeprojPathForPlugin:(Plugin *)plugin {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    @try {
        NSString *path = [self pathForClonedPlugin:plugin];
        NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:path];
        NSLog(@"Enumerator: %@", enumerator);
        
        NSString *directoryEntry;
        while (directoryEntry = [enumerator nextObject]) {
            NSLog(@"Parsing directory entry... %@", directoryEntry);
            if ([[directoryEntry substringWithRange:NSMakeRange(directoryEntry.length -1, -10)] isEqualToString:@".xcodeproj"]) {
                NSLog(@"found xcodeproj!!!! %@", directoryEntry);
                return directoryEntry;
            }
        }
    }
    @catch (NSException *exception) { NSLog(@"Exception with finding xcodeproj path! %@", exception); }
    @finally { NSLog(@"draining..."); [pool drain]; }

    return @"";
}

@end
