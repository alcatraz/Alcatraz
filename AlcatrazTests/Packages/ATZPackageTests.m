//
//  ATZPackageTests.m
//  Alcatraz
//
//  Created by Delisa Mason on 5/14/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Kiwi.h"
#import "ATZPackage.h"
#import "ATZInstaller.h"

SPEC_BEGIN(ATZPackageTests)

describe(@"Package", ^{

    __block ATZPackage *package;
    NSString *name = @"Life";
    NSString *description = @"A short game of numbers";
    NSString *urlString = @"http://raw.github.com/namespace/repo/branch/file";
    NSString *screenshotPath = @"http://HAIKittenImages.com/image.jpeg";

    beforeEach(^{
        package = [[ATZPackage alloc] initWithDictionary:@{
            @"name"        : name,
            @"description" : description,
            @"url": urlString,
            @"screenshot": screenshotPath
        }];
    });

    it(@"initializes correctly", ^{
        [[package.name should] equal:name];
        [[package.description should] equal:description];
        [[package.remotePath should] equal:urlString];
        [[package.screenshotPath should] equal:screenshotPath];
    });
    
    describe(@"parsing website", ^{
        
        it(@"creates project page URL from raw github URL", ^{
            [[package.website should] matchPattern:@"^http[s]?://github.com/[\\w]+/[\\w]+$"];
        });
        
        it(@"preserves URL when not a raw github URL", ^{
            package.remotePath = @"http://git.example.com/life.git";
            [[package.website should] equal:package.remotePath];
        });
        
    });
    
    describe(@"parsing revisions", ^{
        
        it(@"parses branch", ^{
            ATZPackage *newPackage = [[ATZPackage alloc] initWithDictionary:@{ @"branch": @"deploy" }];
            [[newPackage.revision should] equal:@"origin/deploy"];
        });
        
        it(@"parses tag", ^{
            ATZPackage *newPackage = [[ATZPackage alloc] initWithDictionary:@{ @"tag": @"3.4.2" }];
            [[newPackage.revision should] equal:@"3.4.2"];
        });
        
        it(@"parses commit", ^{
            ATZPackage *newPackage = [[ATZPackage alloc] initWithDictionary:@{ @"commit": @"23kjnrq98kcq2jn" }];
            [[newPackage.revision should] equal:@"23kjnrq98kcq2jn"];
        });
        
    });
    
    describe(@"installing", ^{
        
        KWMock *mockInstaller = [ATZInstaller nullMock];
        // haven't succeeded to test that the right args were passed in. brain stopped.
        void (^progressBlock)(NSString *) = ^(NSString *proggressMessage){};
        void (^completionBlock)(NSError *) = ^(NSError *failure){};

        beforeEach(^{
           [package stub:@selector(installer) andReturn:mockInstaller];
        });
       
        it(@"asks installer if it's installed", ^{
            [[mockInstaller should] receive:@selector(isPackageInstalled:) andReturn:@YES];
            [[@(package.isInstalled) should] equal:@YES];
        });
        
        it(@"forwards install to installer", ^{
            [[mockInstaller should] receive:@selector(installPackage:progress:completion:)];
            [package installWithProgressMessage:progressBlock completion:completionBlock];
        });
        
        it(@"forwards remove to installer", ^{
            [[mockInstaller should] receive:@selector(removePackage:completion:)];
            [package removeWithCompletion:completionBlock];
        });
        
        it(@"forwards update to installer", ^{
            [[mockInstaller should] receive:@selector(updatePackage:progress:completion:)];
            [package updateWithProgressMessage:progressBlock completion:completionBlock];
        });
        
    });

});

SPEC_END
