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

describe(@"unpacking package", ^{

    __block ATZPackage *package;

    beforeEach(^{
        package = [[ATZPackage alloc] initWithDictionary:@{
            @"name"        : @"Life",
            @"description" : @"A short game of numbers"
        }];
    });

    it(@"creates project page URL from raw github URL", ^{
        NSString *userName = @"userName";
        NSString *repoName = @"lifeRepo";
        package.remotePath = [NSString stringWithFormat:@"http://raw.github.com/%@/%@/branch/file",userName,repoName];
        
        [[package.website should] startWithString:@"https://github.com"];
        [[package.website should] containString:userName];
        [[package.website should] containString:repoName];
    });

    it(@"preserves URL when not a raw github URL", ^{
        package.remotePath = @"http://git.example.com/life.git";
        [[package.website should] equal:package.remotePath];
    });
    
    context(@"parsing revisions", ^{
        
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
    
    
});

SPEC_END
