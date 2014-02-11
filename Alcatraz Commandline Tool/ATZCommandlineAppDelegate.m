//
//  ATZCommandlineAppDelegate.m
//  Alcatraz
//
//  Created by Boris Bügling on 11.02.14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import "ATZCommandlineAppDelegate.h"
#import "ATZCommandlineInstaller.h"

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
        [ATZCommandlineInstaller installPackageNamed:limitToPackage fromPackages:packages];
    }
}

@end
