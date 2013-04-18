//
//  Installer.h
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Package;

@protocol Installer <NSObject>

- (void)installPackage:(Package *)package progress:(void(^)(CGFloat progress))progress
            completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure;

- (void)removePackage:(Package *)package progress:(void(^)(CGFloat progress))progress
           completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure;

- (BOOL)isPackageInstalled:(Package *)package;

@end
