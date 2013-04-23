// ColorSchemeInstaller.m
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


#import "ColorSchemeInstaller.h"
#import "ColorScheme.h"

static NSString *const LOCAL_COLOR_SCHEMES_RELATIVE_PATH = @"Library/Developer/Xcode/UserData/FontAndColorThemes";
@implementation ColorSchemeInstaller

#pragma mark - Public

- (void)installPackage:(ColorScheme *)package progress:(void(^)(NSString *))progress
            completion:(void(^)(NSError *error))completion {

    Downloader *downloader = [Downloader new];
    [downloader downloadFileFromPath:package.remotePath completion:^(NSData *responseData) {

        [self installColorScheme:package progress:progress withContents:responseData] ?
            completion(nil) :
            completion([NSError errorWithDomain:@"Color Scheme Installation fail" code:666 userInfo:nil]);
        
        [downloader release];
    }
        failure:^(NSError *error) {
            completion(error);
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

- (BOOL)installColorScheme:(ColorScheme *)colorScheme progress:(void(^)(NSString *))progress withContents:(NSData *)contents {
    progress([NSString stringWithFormat:@"Downloading %@", colorScheme.name]);
    
    BOOL installSucceeded = ([[NSFileManager sharedManager] createFileAtPath:[self pathForInstalledPackage:colorScheme]
                                                                    contents:contents
                                                                  attributes:nil]);
    return installSucceeded;
}

- (NSString *)pathForInstalledPackage:(Package *)package {
    return [[NSHomeDirectory() stringByAppendingPathComponent:LOCAL_COLOR_SCHEMES_RELATIVE_PATH]
                               stringByAppendingPathComponent:[package.name stringByAppendingString:@".dvtcolortheme"]];
}

@end
