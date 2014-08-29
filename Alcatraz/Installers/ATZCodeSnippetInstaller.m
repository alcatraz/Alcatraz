//  ATZSnippetInstaller.m
//
// Copyright (c) 2014 Mark Schall | Detroit Labs
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

#import "ATZCodeSnippetInstaller.h"
#import "ATZPackage.h"
#import "ATZGit.h"

static NSString *const INSTALLED_CODE_SNIPPETS_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/CodeSnippets";
static NSString *const DOWNLOADED_CODE_SNIPPETS_RELATIVE_PATH = @"CodeSnippets";

@implementation ATZCodeSnippetInstaller

#pragma mark - Abstract

- (void)downloadPackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {
    [ATZGit cloneRepository:package.remotePath toLocalPath:[self pathForDownloadedPackage:package]
                 completion:completion];
}

- (void)updatePackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {
    [ATZGit updateRepository:[self pathForDownloadedPackage:package] revision:package.revision
                  completion:completion];
}

- (void)installPackage:(ATZPackage *)package completion:(void(^)(NSError *))completion {
    [self copySnippetsToXcode:package completion:completion];
}

- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    return [NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_CODE_SNIPPETS_RELATIVE_PATH];
}

- (NSString *)downloadRelativePath {
    return DOWNLOADED_CODE_SNIPPETS_RELATIVE_PATH;
}

#pragma mark - Private

- (void)copySnippetsToXcode:(ATZPackage *)snippet completion:(void (^)(NSError *))completion {
    NSError *error = nil;
    [self createSnippetInstallDirectory:snippet error:&error];
    
    if (error) {
        completion(error);
    }
    
    for (NSString *snippetPath in [self templateFilesForClonedTemplate:snippet]) {
        [self installCodeSnippetFromPath:snippetPath error:&error];
    }
    
    completion(error);
}

- (void)createSnippetInstallDirectory:(ATZPackage *)snippet error:(NSError **)error {
    [[NSFileManager sharedManager] createDirectoryAtPath:[self pathForInstalledPackage:snippet]
                             withIntermediateDirectories:YES attributes:nil error:error];
}

- (NSArray *)templateFilesForClonedTemplate:(ATZPackage *)snippet {
    @autoreleasepool {
        NSString *clonePath = [self pathForDownloadedPackage:snippet];
        NSMutableArray *foundTemplates = [NSMutableArray new];
        
        @try {
            NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonePath];
            NSString *directoryEntry;
            
            while (directoryEntry = [enumerator nextObject]) {
                if ([directoryEntry hasSuffix:snippet.extension])
                    [foundTemplates addObject:[clonePath stringByAppendingPathComponent:directoryEntry]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception occurred while loading template files from clone: %@", exception);
        }
        return foundTemplates;
    }
}

- (void)installCodeSnippetFromPath:(NSString*)snippetPath error:(NSError **)error {
    NSMutableDictionary *snippetDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:snippetPath];
    
    NSString *snippetFileName = snippetPath.pathComponents.lastObject;
    NSString *installPath = [[self pathForInstalledPackage:nil] stringByAppendingPathComponent:snippetFileName];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    [snippetDictionary setValue:uuid forKey:@"IDECodeSnippetIdentifier"];
    
    [snippetDictionary writeToFile:installPath atomically:YES];
}

@end
