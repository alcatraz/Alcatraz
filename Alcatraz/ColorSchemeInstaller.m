//
//  ColorSchemeInstaller.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ColorSchemeInstaller.h"
#import "ColorScheme.h"
@implementation ColorSchemeInstaller

#pragma mark - Public

- (void)installPackage:(ColorScheme *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (void)removePackage:(ColorScheme *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (BOOL)isPackageInstalled:(Package *)package {
    return NO;
}

@end
