//
//  ATZAlcatrazPackage.m
//  Alcatraz
//
//  Created by Marin Usalj on 5/12/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZAlcatrazPackage.h"
#import "ATZPluginInstaller.h"

@implementation ATZAlcatrazPackage

- (ATZInstaller *)installer {
    return [ATZPluginInstaller sharedInstaller];
}

+ (void)update {
    ATZPackage *alcatraz = [[ATZAlcatrazPackage alloc] initWithDictionary:@{
                           @"name": @"Alcatraz",
                           @"url": @"https://github.com/mneorr/Alcatraz",
                           @"description": @"Self updating installer",
                           @"branch": @"deploy"
                           }];
    
    [alcatraz updateWithProgressMessage:^(NSString *proggressMessage){} completion:^(NSError *failure) {
        if (failure)
            NSLog(@"Alcatraz update failed! %@", failure);
        [alcatraz release];
    }];
}

@end
