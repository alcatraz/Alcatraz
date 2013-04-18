//
//  PluginInstaller.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "PluginInstaller.h"
#import "Plugin.h"

@implementation PluginInstaller

#pragma mark - Public

- (void)installPackage:(Plugin *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (void)removePackage:(Plugin *)package progress:(void (^)(CGFloat))progress
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (BOOL)isPackageInstalled:(Package *)package {
    return NO;
}

@end
