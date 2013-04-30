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
#import "ATZGit.h"

static NSString *const XCSNIPPET = @".codesnippet";
static NSString *const LOCAL_SNIPPETS_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/CodeSnippets";

@implementation ATZSnippetInstaller


- (void)installPackage:(ATZSnippet *)package progress:(void (^)(NSString *))progress completion:(void (^)(NSError *))completion {
    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, package.name]);
    [ATZGit updateOrCloneRepository:package.remotePath toLocalPath:[self pathForClonedPackage:package]
                         completion:^(NSError *error) {

         if (error) completion(error);
         else {
             progress([NSString stringWithFormat:INSTALLING_FORMAT, package.name]);
             [self copySnippetsToXcode:package progress:progress completion:completion];
         }
     }];
}

- (void)removePackage:(ATZSnippet *)package completion:(void (^)(NSError *))completion {
    for (NSString *snippetFilePath in [self installedSnippetFilePathsFromPackage:package]) {
        [[NSFileManager sharedManager] removeItemAtPath:snippetFilePath completion:completion];
    }
}

- (BOOL)isPackageInstalled:(ATZSnippet *)package {
    return [self installedSnippetFilePathsFromPackage:package].count > 0;
}

#pragma mark - Private

- (NSString *)pathForInstalledPackage:(ATZSnippet *)package {
    return [[self snippetsPath] stringByAppendingPathComponent:package.name];
}

- (NSString *)pathForClonedPackage:(ATZSnippet *)package {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:package.name];
}

- (void)copySnippetsToXcode:(ATZSnippet *)snippet progress:(void(^)(NSString *))progress completion:(void (^)(NSError *))completion {
    NSError *error = nil;

    for (NSString *snippetPath in [self snippetFilesFromClonedDirectory:[self pathForClonedPackage:snippet]]) {

        NSString *fileName = snippetPath.pathComponents.lastObject;
        if (![self isFileName:fileName inPackage:snippet]) fileName = [NSString stringWithFormat:@"%@_%@", snippet.name, fileName];

        NSString *installPath = [[self snippetsPath] stringByAppendingPathComponent:fileName];

        [[NSFileManager sharedManager] copyItemAtPath:snippetPath toPath:installPath error:&error];
    }

    completion(error);
}

- (NSString *)snippetsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:LOCAL_SNIPPETS_RELATIVE_PATH];
}

- (NSArray *)installedSnippetFilePathsFromPackage:(ATZSnippet *)package {
    @autoreleasepool {
        NSMutableArray *foundSnippets = [NSMutableArray new];
        @try {
            NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:[self snippetsPath]];
            NSString *directoryEntry;

            while (directoryEntry = [enumerator nextObject]) {
                if ([self isFileName:directoryEntry inPackage:package] && [self isFilePathForSnippet:directoryEntry])
                    [foundSnippets addObject:[[self snippetsPath] stringByAppendingPathComponent:directoryEntry]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"An exception occurred while enumerating snippets: %@",exception);
        }
        return [foundSnippets autorelease];
    }
}

- (NSArray *)snippetFilesFromClonedDirectory:(NSString *)clonePath {
    @autoreleasepool {
        NSMutableArray *foundSnippets = [NSMutableArray new];
        @try {
            NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonePath];
            NSString *directoryEntry;

            while (directoryEntry = [enumerator nextObject]) {
                if ([self isFilePathForSnippet:directoryEntry])
                    [foundSnippets addObject:[clonePath stringByAppendingPathComponent:directoryEntry]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"An exception occurred while enumerating snippets in %@: %@",clonePath, exception);
        }
        return [foundSnippets autorelease];
    }
}

- (BOOL) isFilePathForSnippet:(NSString *)filePath {
    return [filePath hasSuffix:XCSNIPPET];
}

- (BOOL) isFileName:(NSString *) name inPackage:(ATZSnippet *)package {
    return [name hasPrefix:package.name];
}

@end
