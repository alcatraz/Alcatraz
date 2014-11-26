//
//  ATZCommandlineInstaller.m
//  Alcatraz
//
//  Created by Boris Bügling on 11.02.14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ATZCommandlineInstaller.h"
#import "ATZPackage.h"
#import "ATZPackageFactory.h"

@implementation ATZCommandlineInstaller

+(void)installPackage:(ATZPackage*)package completion:(void (^)(NSError *))completion {
    [package installWithProgress:^(NSString *proggressMessage, CGFloat progress) {
        NSLog(@"%.2f %@", progress, proggressMessage);
    } completion:completion];
}

+(void)installPackageNamed:(NSString*)name fromPackages:(NSArray*)packages {
    BOOL found = NO;
    
    for (ATZPackage* package in packages) {
        if ([package.name isEqualToString:name]) {
            found = YES;
            
            [self installPackage:package completion:^(NSError* failure) {
                if (failure) {
                    NSLog(@"Error: %@", failure.localizedDescription);
                }
                
                [NSApp terminate:nil];
            }];
        }
    }
    
    if (!found) {
        NSLog(@"Package not found: %@", name);
        [NSApp terminate:nil];
    }
}

+(NSArray*)loadPackagesAtPath:(NSString*)path error:(NSError**)error {
    NSData* jsonData = [NSData dataWithContentsOfFile:path];
    if (!jsonData) {
        if (error) {
            *error = [NSError errorWithDomain:nil
                                         code:0
                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@: No such file or directory", path] }];
        }
        
        return nil;
    }
    
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    if (!dict) {
        return nil;
    }
    
    return [ATZPackageFactory createPackagesFromDicts:dict[@"packages"]];
}

@end
