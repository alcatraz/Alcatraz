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


#import "ColorSchemeInstaller.h"
#import "ColorScheme.h"

static NSString *const LOCAL_COLOR_SCHEMES_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/FontAndColorThemes";
@implementation ColorSchemeInstaller

#pragma mark - Public

- (void)installPackage:(ColorScheme *)package progress:(void(^)(NSString *))progress
            completion:(void(^)(NSError *error))completion {

    progress([NSString stringWithFormat:DOWNLOADING_FORMAT, package.name]);
    
    Downloader *downloader = [Downloader new];
    [downloader downloadFileFromPath:package.remotePath completion:^(NSData *responseData, NSError *error) {
        
        if (error) completion(error);
        progress([NSString stringWithFormat:INSTALLING_FORMAT, package.name]);
        
        [self installColorScheme:package withContents:responseData completion:completion];
        [downloader release];
    }];
}

- (void)removePackage:(ColorScheme *)package completion:(void (^)(NSError *))completion {

    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPackage:package]
                                         completion:completion];
}

- (BOOL)isPackageInstalled:(ColorScheme *)package {
    
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package]];
}

#pragma mark - Private

- (void)installColorScheme:(ColorScheme *)colorScheme withContents:(NSData *)contents
                completion:(void(^)(NSError *error))completion {
    BOOL installSucceeded = ([[NSFileManager sharedManager] createFileAtPath:[self pathForInstalledPackage:colorScheme]
                                                                    contents:contents
                                                                  attributes:nil]);
    installSucceeded ? completion(nil) :
                       completion([NSError errorWithDomain:@"Color Scheme Installation fail" code:666 userInfo:nil]);
}

- (NSString *)pathForInstalledPackage:(Package *)package {
    return [[NSHomeDirectory() stringByAppendingPathComponent:LOCAL_COLOR_SCHEMES_RELATIVE_PATH]
                               stringByAppendingPathComponent:[package.name stringByAppendingString:@".dvtcolortheme"]];
}

@end
