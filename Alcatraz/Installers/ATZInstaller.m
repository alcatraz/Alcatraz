// ATZInstaller.m
// 
// Copyright (c) 2013 supermar.in
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
const CGFloat ATZFakeDownloadProgress = 0.33;
const CGFloat ATZFakeInstallProgress = 0.66;

@implementation ATZInstaller

#pragma mark - Singleton

+ (instancetype)sharedInstaller {
    static NSMutableDictionary *instances;
    
    @synchronized(self) {
        if (instances == nil) instances = [NSMutableDictionary new];
        if (instances[self] == nil)
            instances[(id<NSCopying>)self] = [[self alloc] init];
    }
    return instances[self];
}

#pragma mark - Public

- (void)installPackage:(ATZPackage *)package progress:(void(^)(NSString *, CGFloat))progress
            completion:(void(^)(NSError *error))completion {

    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, package.name], ATZFakeDownloadProgress);
    [self downloadOrUpdatePackage:package completion:^(NSString *output, NSError *error) {
       
        if (error) { completion(error); return; }
        progress([NSString stringWithFormat:INSTALLING_FORMAT, package.name], ATZFakeInstallProgress);
        
        [self installPackage:package completion:^(NSError *error) {
            if (error) {
                completion(error);
            } else {
                [self reloadXcodeForPackage:package completion:completion];
            }
        }];
    }];
}

- (void)updatePackage:(ATZPackage *)package progress:(void(^)(NSString *, CGFloat))progress
           completion:(void(^)(NSError *error))completion {
    
    progress([NSString stringWithFormat:UPDATING_FORMAT, package.name], ATZFakeDownloadProgress);
    [self downloadOrUpdatePackage:package completion:^(NSString *output, NSError *error) {
        
        BOOL needsUpdate = output.length > 0;
        if (error || !needsUpdate) { completion(error); return; }

        progress([NSString stringWithFormat:INSTALLING_FORMAT, package.name], ATZFakeInstallProgress);
        [self installPackage:package completion:completion];
    }];
}

- (void)removePackage:(ATZPackage *)package completion:(void (^)(NSError *))completion {
    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPackage:package] completion:completion];
}

- (BOOL)isPackageInstalled:(ATZPackage *)package {
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package]];
}

- (NSString *)pathForDownloadedPackage:(ATZPackage *)package {
    return [[[self alcatrazDownloadsPath] stringByAppendingPathComponent:[self downloadRelativePath]]
                                           stringByAppendingPathComponent:package.name];
}


#pragma mark - Abstract

- (NSString *)alcatrazDownloadsPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:ALCATRAZ_DATA_DIR];
}


- (void)downloadPackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Abstract Installer doesn't know how to download" userInfo:nil];
}

- (void)updatePackage:(ATZPackage *)package completion:(void(^)(NSString *, NSError *))completion {
    @throw [NSException exceptionWithName:@"Abstract Installer"
                                   reason:@"Abstract Installer doesn't know how to update" userInfo:nil];
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



#pragma mark - Private

- (void)downloadOrUpdatePackage:(ATZPackage *)package completion:(void (^)(NSString *, NSError *))completion {
    
    if ([[NSFileManager sharedManager] fileExistsAtPath:[self pathForDownloadedPackage:package]])
        [self updatePackage:package completion:^(NSString *output, NSError *error) {
            completion(output, error);
        }];
    else
        [self downloadPackage:package completion:completion];
}

@end
