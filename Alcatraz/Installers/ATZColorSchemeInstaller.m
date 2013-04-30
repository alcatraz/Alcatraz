// ColorSchemeInstaller.m
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


#import "ATZColorSchemeInstaller.h"
#import "ATZColorScheme.h"

static NSString *const INSTALLED_COLOR_SCHEMES_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/FontAndColorThemes";
static NSString *const DOWNLOADED_COLOR_SCHEMES_RELATIVE_PATH = @"FontAndColorThemes";

@implementation ATZColorSchemeInstaller

#pragma mark - Abstract

- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    return [[[self colorSchemesPath] stringByAppendingPathComponent:package.name]
                                            stringByAppendingString:COLOR_SCHEME_EXTENSION];
}


- (NSString *)pathForClonedPackage:(ATZPackage *)package {
    return [[self alcatrazDownloadsPath] stringByAppendingPathComponent:DOWNLOADED_COLOR_SCHEMES_RELATIVE_PATH];
}

- (void)downloadOrUpdatePackage:(ATZPackage *)package completion:(void (^)(NSError *))completion {
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadFileFromPath:package.remotePath completion:^(NSData *responseData, NSError *error) {
        
        if (error) completion(error);
        
        [self saveColorScheme:package withContents:responseData completion:completion];
        
        [downloader release];
    }];
}

- (void)installPackage:(ATZColorScheme *)package completion:(void (^)(NSError *))completion {
    [self createColorsDirectoryIfNeeded];
    
    NSError *error = nil;
    [[NSFileManager sharedManager] linkItemAtPath:[self pathForClonedPackage:package]
                                           toPath:[self pathForInstalledPackage:package] error:&error];
    completion(error);
}


#pragma mark - Private

- (void)saveColorScheme:(ATZPackage *)colorScheme withContents:(NSData *)contents
             completion:(void(^)(NSError *error))completion {
    
    
    BOOL saveSucceeded = ([[NSFileManager sharedManager] createFileAtPath:[self pathForClonedPackage:colorScheme]
                                                                 contents:contents attributes:nil]);
    saveSucceeded ? completion(nil) :
                       completion([NSError errorWithDomain:@"Color Scheme Installation fail" code:666 userInfo:nil]);
}

- (void)createColorsDirectoryIfNeeded {

    if (![[NSFileManager sharedManager] fileExistsAtPath:[self colorSchemesPath]]) {
     
        [[NSFileManager sharedManager] createDirectoryAtPath:[self colorSchemesPath]
                                 withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)colorSchemesPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:INSTALLED_COLOR_SCHEMES_RELATIVE_PATH];
}

@end
