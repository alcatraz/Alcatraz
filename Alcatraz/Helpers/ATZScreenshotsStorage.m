//
//  ATZScreenshotsStorage.m
//  Alcatraz
//
//  Created by Alex Antonyuk on 3/20/15.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import "ATZScreenshotsStorage.h"
#import <AppKit/AppKit.h>
#import "ATZDownloader.h"
#import "ATZPackage.h"

@implementation ATZScreenshotsStorage

#pragma mark - Image Previews

+ (NSCache *)imageCache {
	static NSCache* cache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [[NSCache alloc] init];
	});
	return cache;
}

+ (NSImage *)cachedImageForPackage:(ATZPackage*)package {
	return [[self imageCache] objectForKey:package.name];
}

+ (void)cacheImage:(NSImage *)image forPackage:(ATZPackage *)package {
	[[self imageCache] setObject:image forKey:package.name];
}

+ (void)fetchAndCacheImageForPackage:(ATZPackage*)package progress:(void(^)(CGFloat))progress completion:(ATZImagesStorageCompletion)completion {
	ATZDownloader *downloader = [ATZDownloader new];
	[downloader downloadFileFromPath:package.screenshotPath
							progress:progress
						  completion:^(NSData *responseData, NSError *error) {
							  if (error) {
								  return;
							  }

							  NSImage *image = [[NSImage alloc] initWithData:responseData];
							  if (!image) {
								  return;
							  }

							  [self cacheImage:image forPackage:package];
							  if (completion) {
								  completion(package, image);
							  }
						  }];
}

@end
