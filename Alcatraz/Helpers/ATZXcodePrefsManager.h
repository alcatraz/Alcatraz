//
//  ATZXcodePrefsManager.h
//  Alcatraz
//
//  Created by Guillaume Algis on 14/07/2015.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ATZPackage;

@interface ATZXcodePrefsManager : NSObject

+ (instancetype)sharedManager;

- (void)whitelistPackage:(ATZPackage *)package completion:(void(^)(NSError *error))completion;
- (BOOL)isPackageBlacklisted:(ATZPackage *)package;

@end
