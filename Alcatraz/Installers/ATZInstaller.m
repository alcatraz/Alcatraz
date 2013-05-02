// ATZInstaller.m
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

#import "ATZInstaller.h"
#import "ATZPackage.h"

static NSString *const ALCATRAZ_DATA_DIR = @"Library/Application Support/Alcatraz";

@implementation ATZInstaller

- (void)installPackage:(ATZPackage *)package progress:(void(^)(NSString *progressMessage))progress
            completion:(void(^)(NSError *error))completion {
    
    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, package.name]);
    [self downloadOrUpdatePackage:package completion:^(NSString *output, NSError *error) {
       
        if (error) completion(error);
        progress([NSString stringWithFormat:INSTALLING_FORMAT, package.name]);
        
        [self installPackage:package completion:^(NSError *error) {
            
            if (error) completion (error);
            [self reloadXcodeForPackage:package completion:completion];
        }];
    }];
}

- (void)removePackage:(ATZPackage *)package completion:(void (^)(NSError *))completion {
    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPackage:package] completion:completion];
}

- (BOOL)isPackageInstalled:(ATZPackage *)package {
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package]];
}

- (NSString *)alcatrazDownloadsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:ALCATRAZ_DATA_DIR];
}

- (NSString *)pathForDownloadedPackage:(ATZPackage *)package {
    return [[[self alcatrazDownloadsPath] stringByAppendingPathComponent:[self downloadRelativePath]]
                                           stringByAppendingPathComponent:package.name];
}


#pragma mark - Abstract

- (void)downloadOrUpdatePackage:(ATZPackage *)package completion:(void (^)(NSString *, NSError *))completion {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Abstract Installer doesn't know how to download" userInfo:nil];
}

- (void)installPackage:(ATZPackage *)package completion:(void(^)(NSError *))completion {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Abstract Installer doesn't know how to install" userInfo:nil];
}


- (NSString *)pathForInstalledPackage:(ATZPackage *)package {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Install path is different for every package type" userInfo:nil];
}

- (NSString *)downloadRelativePath {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Download path is different for every package type" userInfo:nil];
}


#pragma mark - Hooks

- (void)reloadXcodeForPackage:(ATZPackage *)package completion:(void(^)(NSError *))completion{ completion(nil); }

@end
