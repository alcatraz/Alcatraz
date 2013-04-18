//
//  Package.h
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Installer;


@interface Package :NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic) BOOL isInstalled;

- (id)initWithDictionary:(NSDictionary *)dict;

- (void)installWithProgress:(void(^)(CGFloat progress))progress
                 completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure;

- (void)removeWithProgress:(void(^)(CGFloat progress))progress
                completion:(void(^)(void))completion failure:(void(^)(NSError *error))failure;


/// To be overriden in subclasses. Each type of package has a different installer.
#pragma mark - Abstract

- (id<Installer>)installer;

@end
