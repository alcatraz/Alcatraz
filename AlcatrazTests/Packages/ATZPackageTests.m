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
    __block NSString   *userName = @"userName";
    __block NSString   *repoName = @"lifeRepo";

    beforeAll(^{
        package = [[ATZPackage alloc] initWithDictionary:@{
            @"name"        : @"Life",
            @"description" : @"A short game of numbers"
        }];
    });

    it(@"creates project page URL from raw github URL", ^{
        package.remotePath = [NSString stringWithFormat:@"http://raw.github.com/%@/%@/branch/file",userName,repoName];
        NSString *website = [package website];
        [[theValue([website rangeOfString:@"https://github.com"].location) should] equal:@0];
        [[theValue([website rangeOfString:userName].location) shouldNot] equal:theValue(NSNotFound)];
        [[theValue([website rangeOfString:repoName].location) shouldNot] equal:theValue(NSNotFound)];
//        [[website should] startWithString:@"https://github.com"];
//        [[website should] containString:userName];
//        [[website should] containString:repoName];
    });

    it(@"preserves URL when not a raw github URL", ^{
        package.remotePath = @"http://git.example.com/life.git";
        [[[package website] should] equal:package.remotePath];
    });
});

SPEC_END
