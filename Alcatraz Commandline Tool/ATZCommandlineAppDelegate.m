//
//  ATZCommandlineAppDelegate.m
//  Alcatraz
//
//  Created by Boris Bügling on 11.02.14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import "ATZCommandlineAppDelegate.h"
#import "ATZCommandlineInstaller.h"
#import "ATZPackage.h"

@implementation ATZCommandlineAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    if (arguments.count < 2) {
        NSLog(@"Please specify the path to your packages.json");
        exit(1);
    }
    
    NSString* path = arguments[1];
    if (!path.isAbsolutePath) {
        NSString* srcRoot = [[NSProcessInfo processInfo] environment][@"SRCROOT"];
        path = [srcRoot stringByAppendingPathComponent:path];
    }
    
    NSString* limitToPackage = nil;
    if (arguments.count > 2) {
        limitToPackage = arguments[2];
    }
    
    NSError* error;
    NSArray* packages = [ATZCommandlineInstaller loadPackagesAtPath:path error:&error];
    
    if (!packages) {
        NSLog(@"%@", error.localizedDescription);
    } else {
        if (limitToPackage) {
            [ATZCommandlineInstaller installPackageNamed:limitToPackage fromPackages:packages];
        } else {
            __block BOOL doneWithPackage = NO;
            NSMutableArray* failedPackages = [@[] mutableCopy];
            
            for (ATZPackage* package in packages) {
                @try {
                    [ATZCommandlineInstaller installPackage:package completion:^(NSError* failure) {
                        if (failure) {
                            [failedPackages addObject:package];
                        }
                        
                        [package removeWithCompletion:^(NSError *failure) {
                            doneWithPackage = YES;
                        }];
                    }];
                } @catch(NSException *exception) {
                    doneWithPackage = YES;
                    
                    [failedPackages addObject:package];
                }
                
                while (!doneWithPackage) {
                    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
                }
                
                doneWithPackage = NO;
            }
            
            NSLog(@"The following packages could not be installed: %@", [failedPackages valueForKey:@"name"]);
            [NSApp terminate:nil];
        }
    }
}

@end
