//
// ATZCache.m
//
// Copyright (c) 2014 Marin Usalj | supermar.in
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

#import "ATZCache.h"
#import "Alcatraz.h"

static NSString *const PACKAGES_CACHE_FILENAME = @"packages.plist";

@implementation ATZCache

+ (NSDictionary *)loadPackagesFromCache {
    return [NSDictionary dictionaryWithContentsOfURL:[self packagesCacheURL]];
}

+ (BOOL)cachePackages:(NSDictionary *)packages {
    NSError *error;

    BOOL directoryExists = [self createCacheDirectoryIfNeeded:&error];
    if (!directoryExists) {
        NSLog(@"Error while caching packages: %@", error.localizedDescription);
        return NO;
    }

    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:packages format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if (!plistData) {
        NSLog(@"Error while serializing packages for caching: %@", error.localizedDescription);
        return NO;
    }

    return [plistData writeToURL:[self packagesCacheURL] atomically:YES];
}

+ (NSURL *)cacheDirectoryURL {
    NSURL *mainCacheDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *bundleIdentifier = [Alcatraz sharedPlugin].bundle.bundleIdentifier;
    NSURL *cacheDirectory = [mainCacheDirectory URLByAppendingPathComponent:bundleIdentifier];

    return cacheDirectory;
}

+ (NSURL *)packagesCacheURL {
    return [[self cacheDirectoryURL] URLByAppendingPathComponent:PACKAGES_CACHE_FILENAME];
}

+ (BOOL)createCacheDirectoryIfNeeded:(NSError **)error {
    BOOL created = [[NSFileManager defaultManager] createDirectoryAtURL:[self cacheDirectoryURL] withIntermediateDirectories:YES attributes:nil error:error];

    if (!created) {
        NSString *errorDescription = error ? (*error).localizedDescription : nil;
        NSLog(@"Could not find a valid caching directory: %@", errorDescription);
    }

    return created;
}

@end
