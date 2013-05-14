//
// ATZPackageFactoryTests.m
//
// Copyright (c) 2013 Marin Usalj | mneorr.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "Kiwi.h"
#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZProjectTemplate.h"
#import "ATZFileTemplate.h"
#import "ATZPackageFactory.h"

SPEC_BEGIN(ATZPackageFactoryTests)

describe(@"ATZPackageFactory.m", ^{

    beforeAll(^{
        [ATZPackageFactory initialize];
    });

    describe(@"creating packages from dictionaries", ^{
        it(@"should create a plugin from a dictionary", ^{
            NSDictionary *inputData = @{@"plugins": @[@{
                @"name": @"CoolPlugin",
                @"url": @"http://git.example.com/cool.git",
                @"description":@"A plugin for making Xcode ...cool. Very cool."
            }]};

            NSArray *packages = [ATZPackageFactory createPackagesFromDicts:inputData];
            [[@(packages.count) should] equal:@1];
            [[packages[0] should] beKindOfClass:[ATZPlugin class]];
        });

        it(@"should create a color scheme from a dictionary", ^{
            NSDictionary *inputData = @{@"color_schemes": @[@{
                @"name": @"Dijkstra in Blue",
                @"url": @"http://git.example.com/dijkstra.dvtcolortheme",
                @"description":@"This theme makes you feel guilty about your poor coding habits"
            }]};

            NSArray *packages = [ATZPackageFactory createPackagesFromDicts:inputData];
            [[@(packages.count) should] equal:@1];
            [[packages[0] should] beKindOfClass:[ATZColorScheme class]];
        });

        it(@"should create a file template from a dictionary", ^{
            NSDictionary *inputData = @{@"file_templates": @[@{
                @"name": @"Kiwi File Templates",
                @"url": @"http://git.example.com/kiwi_themes.git",
                @"description":@"File templates for the Kiwi testing framework"
            }]};

            NSArray *packages = [ATZPackageFactory createPackagesFromDicts:inputData];
            [[@(packages.count) should] equal:@1];
            [[packages[0] should] beKindOfClass:[ATZFileTemplate class]];
        });

        it(@"should create a project template from a dictionary", ^{
            NSDictionary *inputData = @{@"plugins": @[@{
                @"name": @"CoolPlugin",
                @"url": @"http://git.example.com/cool.git",
                @"description":@"A plugin for making Xcode ...cool. Very cool."
            }]};

            NSArray *packages = [ATZPackageFactory createPackagesFromDicts:inputData];
            [[@(packages.count) should] equal:@1];
            [[packages[0] should] beKindOfClass:[ATZPlugin class]];
        });
    });

    it(@"should sort packages by name", ^{
        NSArray *packageNames = @[@"Z",@"D",@"A",@"U"];
        NSDictionary *inputData = @{
            @"plugins": @[@{
                @"name": packageNames[0],
                @"url": @"http://git.example.com/package.git",
                @"description":@"The force from the beginning"
            }],
            @"color_schemes": @[@{
                @"name": packageNames[1],
                @"url": @"http://git.example.com/package.git",
                @"description":@"Our ends were beginnings"
            },@{
                @"name": packageNames[2],
                @"url": @"http://git.example.com/package.git",
                @"description":@"Like the legend of the phoenix"
            }],
            @"project_templates": @[@{
                @"name": packageNames[3],
                @"url": @"http://git.example.com/package.git",
                @"description":@"What keeps the planet spinning"
            }]
        };

        NSArray *packages = [ATZPackageFactory createPackagesFromDicts:inputData];
        [[@(packages.count) should] equal:@4];

        NSArray *sortedPackageNames = [packageNames sortedArrayUsingSelector:@selector(compare:)];
        for(int i = 0; i < packages.count; i++) {
            ATZPackage *package = packages[i];
            [[package.name should] equal: sortedPackageNames[i]];
        }

    });

});

SPEC_END
