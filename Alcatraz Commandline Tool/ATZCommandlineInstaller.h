//
//  ATZCommandlineInstaller.h
//  Alcatraz
//
//  Created by Boris Bügling on 11.02.14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATZPackage;

@interface ATZCommandlineInstaller : NSObject

+(void)installPackage:(ATZPackage*)package completion:(void (^)(NSError *))completion;
+(void)installPackageNamed:(NSString*)name fromPackages:(NSArray*)packages;
+(NSArray*)loadPackagesAtPath:(NSString*)path error:(NSError**)error;

@end
