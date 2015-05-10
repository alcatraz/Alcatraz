//
//  ATZConfig.m
//  Alcatraz
//
//  Created by Max on 09/05/15.
//  Copyright (c) 2013 Marin Usalj | supermar.in
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ATZConfig.h"

static NSString *const ATZ_HTTP_PROXY_KEY = @"ATZGitHttpProxy";
static NSString *const ATZ_FORCE_HTTPS_KEY = @"ATZForceHttps";
static NSString *const ATZ_REPO_KEY = @"ATZRepoPath";
static NSString *const ATZ_DEFAULT_REPO_PATH = @"https://raw.github.com/supermarin/alcatraz-packages/master/packages.json";

@implementation ATZConfig

#pragma mark - Package Repo

+ (NSString *)packageRepoPath {
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:ATZ_REPO_KEY];
    if (!path) {
        path = ATZ_DEFAULT_REPO_PATH;
    }

    return path;
}

+ (void)resetPackageRepoPath {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ATZ_REPO_KEY];
}

+ (void)setPackagesRepoPath:(NSString *)path {
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:ATZ_REPO_KEY];
}

#pragma mark - Http Proxy

+ (NSString *)httpProxy {
    NSString *proxy = [[NSUserDefaults standardUserDefaults] stringForKey:ATZ_HTTP_PROXY_KEY];

    if (!proxy) {
        proxy = @"";
    }

    return proxy;
}

+ (void)resetHttpProxy {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ATZ_HTTP_PROXY_KEY];
}

+ (void)setHttpProxy:(NSString *)proxy {
    [[NSUserDefaults standardUserDefaults] setObject:proxy forKey:ATZ_HTTP_PROXY_KEY];
}

#pragma mark - Http Only

+ (BOOL)forceHttps {
    BOOL forceHttps = [[NSUserDefaults standardUserDefaults] boolForKey:ATZ_FORCE_HTTPS_KEY];

    if (!forceHttps) {
        forceHttps = NO;
    }

    return forceHttps;
}

+ (void)resetForceHttps {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ATZ_FORCE_HTTPS_KEY];
}

+ (void)setForceHttps:(BOOL)forceHttps {
    [[NSUserDefaults standardUserDefaults] setBool:forceHttps forKey:ATZ_FORCE_HTTPS_KEY];
}

@end
