//
//  Package.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Package.h"
#import "Installer.h"

@implementation Package
@dynamic isInstalled;

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (!self) return nil;
    
    [self unpackFromDictionary:dict];
    
    return self;
}

- (void)dealloc {
    [super dealloc];
    [self.name release];
    [self.description release];
    [self.url release];
}


#pragma mark - Private

- (void)unpackFromDictionary:(NSDictionary *)dictionary {
    self.name = [dictionary[@"name"] copy];
    self.description = [dictionary[@"description"] copy];
    self.url = [[NSURL alloc] initWithString:dictionary[@"url"]];
}


#pragma mark - Abstract

- (BOOL)isInstalled {
    return [[self installer] isPackageInstalled:self];
}

- (void)installWithProgress:(void(^)(CGFloat progress))progress
                 completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure {

    [[self installer] installPackage:self progress:progress completion:completion failure:failure];
}

- (void)removeWithProgress:(void(^)(CGFloat progress))progress
                completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure {

    [[self installer] removePackage:self progress:progress completion:completion failure:failure];
}

@end
