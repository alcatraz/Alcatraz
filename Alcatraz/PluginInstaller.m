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

static NSString *const LOCAL_PLUGINS_RELATIVE_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins";

@implementation PluginInstaller

#pragma mark - Public


// TODO: move to git and support updates.
- (void)installPackage:(Plugin *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
//    [Downloader download]
}

- (void)removePackage:(Plugin *)package
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (BOOL)isPackageInstalled:(Plugin *)package {
    return [[NSFileManager sharedManager] fileExistsAtPath:[self filePathForPlugin:package] isDirectory:YES];
}


#pragma mark - Private

- (NSString *)filePathForPlugin:(Plugin *)plugin {
    return [NSString stringWithFormat:@"%@.xcplugin",
            [NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), LOCAL_PLUGINS_RELATIVE_PATH, plugin.name]];
}

@end
