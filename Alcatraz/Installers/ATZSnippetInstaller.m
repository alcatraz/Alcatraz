// ATZSnippetInstaller.m
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

#import "ATZSnippetInstaller.h"
#import "ATZSnippet.h"

static NSString *const XCSNIPPET = @".codesnippet";
static NSString *const XCCOMMAND = @".command";
static NSString *const LOCAL_SNIPPETS_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/CodeSnippets";

@implementation ATZSnippetInstaller


- (void)installPackage:(ATZPackage *)package progress:(void (^)(NSString *))progress completion:(void (^)(NSError *))completion {

}

- (void)removePackage:(ATZPackage *)package completion:(void (^)(NSError *))completion {

}

- (BOOL)isPackageInstalled:(ATZPackage *)package {
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package]];
}

#pragma mark - Private

- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    return [[self snippetsPath] stringByAppendingPathComponent:package.name];
}

- (NSString *)pathForClonedPackage:(ATZPackage *)package {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:package.name];
}

- (void)copySnippetsToXcode:(ATZSnippet *)snippet progress:(void(^)(NSString *))progress completion:(void (^)(NSError *))completion {
    NSError *error = nil;

    [[NSFileManager sharedManager] createDirectoryAtPath:[self pathForInstalledPackage:snippet]
                             withIntermediateDirectories:YES attributes:nil error:&error];

    for (NSString *snippetPath in [self snippetFilesFromClonedDirectory:[self pathForClonedPackage:snippet]]) {

        NSString *fileName = snippetPath.pathComponents.lastObject;
        NSString *installPath = [[self pathForInstalledPackage:snippet] stringByAppendingPathComponent:fileName];

        [[NSFileManager sharedManager] copyItemAtPath:snippetPath toPath:installPath error:&error];
    }

    completion(error);
}

- (NSString *)snippetsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:LOCAL_SNIPPETS_RELATIVE_PATH];
}

- (NSArray *)snippetFilesFromClonedDirectory:(NSString *)clonePath {
    @autoreleasepool {
        NSMutableArray *foundSnippets = [NSMutableArray new];
        @try {
            NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonePath];
            NSString *directoryEntry;

            while (directoryEntry = [enumerator nextObject]) {
                if ([directoryEntry hasSuffix:XCSNIPPET] || [directoryEntry hasSuffix:XCCOMMAND])
                    [foundSnippets addObject:[clonePath stringByAppendingPathComponent:directoryEntry]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"An exception occurred while enumerating snippets in %@: %@",clonePath, exception);
        }
        return [foundSnippets autorelease];
    }
}

@end
