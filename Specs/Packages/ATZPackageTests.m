//
//  ATZPackageTests.m
//  Alcatraz
//
//  Created by Delisa Mason on 5/14/13.
//  Copyright (c) 2013 supermar.in. All rights reserved.
//

#import "Kiwi.h"
#import "ATZPackage.h"
#import "ATZInstaller.h"
#import "Alcatraz.h"

void buildMockInstaller(KWMock *mockInstaller) {
    [mockInstaller stub:@selector(installPackage:progress:completion:) withBlock:^id(NSArray *params) {
        void (^progressCallback)(NSString *) = params[1];
        void (^completionCallback)(NSError *) = params[2];
        
        progressCallback(nil);
        completionCallback(nil);
        return nil;
    }];
    [mockInstaller stub:@selector(updatePackage:progress:completion:) withBlock:^id(NSArray *params) {
        void (^progressCallback)(NSString *) = params[1];
        void (^completionCallback)(NSError *) = params[2];
        
        progressCallback(nil);
        completionCallback(nil);
        return nil;
    }];
    [mockInstaller stub:@selector(removePackage:completion:) withBlock:^id(NSArray *params) {
        void (^completionCallback)(NSError *) = params[1];
        completionCallback(nil);
        return nil;
    }];
}

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
        [[package.summary should] equal:description];
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
        __block NSString *progressMessage;
        __block NSError *completionError;
        
        void (^progressBlock)(NSString *, CGFloat) = ^(NSString *proggressMessage, CGFloat progress){ progressMessage = @"OH HAI!"; };
        void (^completionBlock)(NSError *) = ^(NSError *failure){ completionError = [NSError errorWithDomain:@"MEH" code:666 userInfo:nil]; };

        beforeEach(^{
            progressMessage = nil;
            completionError = nil;
            
            [package stub:@selector(installer) andReturn:mockInstaller];
            buildMockInstaller(mockInstaller);
        });
       
        it(@"asks installer if it's installed", ^{
            [[mockInstaller should] receive:@selector(isPackageInstalled:) andReturn:@YES];
            [[@(package.isInstalled) should] equal:@YES];
        });
        
        it(@"forwards install to installer", ^{
            [package installWithProgress:progressBlock completion:completionBlock];
            [[progressMessage should] equal:@"OH HAI!"];
            [[completionError should] equal:[NSError errorWithDomain:@"MEH" code:666 userInfo:nil]];
        });
        
        it(@"forwards remove to installer", ^{
            [package removeWithCompletion:completionBlock];
            [[completionError should] equal:[NSError errorWithDomain:@"MEH" code:666 userInfo:nil]];
        });
        
        it(@"forwards update to installer", ^{
            [package updateWithProgress:progressBlock completion:completionBlock];
            [[progressMessage should] equal:@"OH HAI!"];
            [[completionError should] equal:[NSError errorWithDomain:@"MEH" code:666 userInfo:nil]];
        });
        
    });

});

SPEC_END
