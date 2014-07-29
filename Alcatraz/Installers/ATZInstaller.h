// Installer.h
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


#import <Foundation/Foundation.h>
#import "ATZDownloader.h"
#import "NSFileManager+Alcatraz.h"

@class ATZPackage;

static NSString *const DOWNLOADING_FORMAT = @"Downloading %@...";
static NSString *const INSTALLING_FORMAT = @"Installing %@...";
static NSString *const UPDATING_FORMAT = @"Updating %@...";

@interface ATZInstaller : NSObject

+ (instancetype)sharedInstaller;

- (void)installPackage:(ATZPackage *)package progress:(void(^)(NSString *progressMessage, CGFloat progress))progress
                                           completion:(void(^)(NSError *error))completion;
- (void)updatePackage:(ATZPackage *)package progress:(void(^)(NSString *progressMessage, CGFloat progress))progress
                                          completion:(void(^)(NSError *error))completion;
- (void)removePackage:(ATZPackage *)package
           completion:(void(^)(NSError *error))completion;


- (BOOL)isPackageInstalled:(ATZPackage *)package;
- (NSString *)pathForDownloadedPackage:(ATZPackage *)package;


#pragma mark - Abstract (Overriden in subclasses)

- (NSString *)pathForInstalledPackage:(ATZPackage *)package;
- (NSString *)downloadRelativePath;


#pragma mark - Hooks

- (void)reloadXcodeForPackage:(ATZPackage *)package completion:(void(^)(NSError *error))completion;

@end
