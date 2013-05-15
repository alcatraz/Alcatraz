//
//  ATZPackageTests.m
//  Alcatraz
//
//  Created by Delisa Mason on 5/14/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Kiwi.h"
#import "ATZPackage.h"

SPEC_BEGIN(ATZPackageTests)

describe(@"parsing website", ^{

    __block ATZPackage *package;
    NSString *userName = @"userName";
    NSString *repoName = @"lifeRepo";

    beforeEach(^{
        package = [[ATZPackage alloc] initWithDictionary:@{
            @"name"        : @"Life",
            @"description" : @"A short game of numbers"
        }];
    });

    it(@"creates project page URL from raw github URL", ^{
        package.remotePath = [NSString stringWithFormat:@"http://raw.github.com/%@/%@/branch/file",userName,repoName];
        
        [[package.website should] startWithString:@"https://github.com"];
        [[package.website should] containString:userName];
        [[package.website should] containString:repoName];
    });

    it(@"preserves URL when not a raw github URL", ^{
        package.remotePath = @"http://git.example.com/life.git";
        [[package.website should] equal:package.remotePath];
    });
});

SPEC_END
