//
//  ATZAlcatrazPackageList.m
//  Alcatraz
//
//  Created by x on 8/9/14.
//  Copyright (c) 2014 supermar.in. All rights reserved.
//

#import "ATZAlcatrazPackageList.h"
#import "ATZPluginInstaller.h"

@implementation ATZAlcatrazPackageList

+ (ATZAlcatrazPackageList *) instance {
    ATZAlcatrazPackageList *alcatraz = [[ATZAlcatrazPackageList alloc] initWithDictionary:@{
        @"name": @"Alcatraz-packages",
        @"url": @"https://github.com/supermarin/alcatraz-packages",
        @"description": @"Alcatraz Package List",
        @"branch": @"master"
    }];
    
    return alcatraz;
}

+ (void)update {
    ATZAlcatrazPackageList *alcatraz = [self instance];
    [alcatraz updateWithProgress:^(NSString *proggressMessage, CGFloat progress){} completion:^(NSError *failure) {
        if (failure)
            NSLog(@"Alcatraz Package List update failed! %@", failure);
    }];
}

+ (NSDictionary *) packages
{
    return [[[self class] instance] packages];
}

- (ATZInstaller *)installer {
    return [ATZPluginInstaller sharedInstaller];
}

- (NSString *) localPath
{
    return [self.installer pathForDownloadedPackage:self];
}

- (NSDictionary *) packages
{
    NSError *error;
    NSString *path = [[self localPath] stringByAppendingPathComponent:@"packages.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error while downloading packages! %@", error);
        return nil;
    } else {
        return JSON[@"packages"];
    }
}

@end
