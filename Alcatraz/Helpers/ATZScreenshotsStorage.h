//
//  ATZScreenshotsStorage.h
//  Alcatraz
//
//  Created by Alex Antonyuk on 3/20/15.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATZPackage;

typedef void(^ATZImagesStorageCompletion)(ATZPackage *pkg, NSImage *image);

@interface ATZScreenshotsStorage : NSObject

+ (NSImage *)cachedImageForPackage:(ATZPackage*)package;
+ (void)cacheImage:(NSImage *)image forPackage:(ATZPackage *)package;
+ (void)fetchAndCacheImageForPackage:(ATZPackage*)package progress:(void(^)(CGFloat))progress completion:(ATZImagesStorageCompletion)completion;

@end
