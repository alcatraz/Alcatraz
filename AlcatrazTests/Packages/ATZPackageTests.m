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
    NSString *namespace = @"userName";
    NSString *repoName = @"lifeRepo";
    NSString *urlString = [NSString stringWithFormat:@"http://raw.github.com/%@/%@/branch/file",namespace,repoName];
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
            [[package.website should] equal:@"https://github.com/userName/lifeRepo"];
        });
        
        it(@"preserves URL when not a raw github URL", ^{
            package.remotePath = @"http://git.example.com/life.git";
            [[package.website should] equal:package.remotePath];
        });
        
    });
    
    describe(@"parsing revisions", ^{
        
        it(@"parses branch", ^{
            package = [[ATZPackage alloc] initWithDictionary:@{ @"branch": @"deploy" }];
            [[package.revision should] equal:@"origin/deploy"];
        });
        
        it(@"parses tag", ^{
            package = [[ATZPackage alloc] initWithDictionary:@{ @"tag": @"3.4.2" }];
            [[package.revision should] equal:@"3.4.2"];
        });
        
        it(@"parses commit", ^{
            package = [[ATZPackage alloc] initWithDictionary:@{ @"commit": @"23kjnrq98kcq2jn" }];
            [[package.revision should] equal:@"23kjnrq98kcq2jn"];
        });
        
    });
    
    it(@"asks installer if it's installed", ^{
        KWMock *mockInstaller = [ATZInstaller mock];
        [package stub:@selector(installer) andReturn:mockInstaller];
        
        [[mockInstaller should] receive:@selector(isPackageInstalled:) andReturn:nil];
        [package isInstalled];
    });
});

SPEC_END
