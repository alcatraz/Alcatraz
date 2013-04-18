//
//  TemplateInstaller.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "TemplateInstaller.h"
#import "Template.h"

@implementation TemplateInstaller

#pragma mark - Public

- (void)installPackage:(Template *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

- (void)removePackage:(Template *)package progress:(void (^)(CGFloat))progress
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    
}

@end
