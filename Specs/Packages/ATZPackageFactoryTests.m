//
// ATZPackageFactoryTests.m
//
// Copyright (c) 2013 Marin Usalj | supermar.in
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

NSDictionary *fakeJSON() {
    return @{
             @"plugins": @[
                     @{
                         @"name": @"D",
                         @"url": @"http://git.example.com/cool.git",
                         @"description": @"A plugin for making Xcode ...cool. Very cool."
                         }],
             @"color_schemes": @[
                     @{
                         @"name": @"B",
                         @"url": @"http://git.example.com/dijkstra.dvtcolortheme",
                         @"description": @"This theme makes you feel guilty about your poor coding habits"
                         }],
             @"file_templates": @[
                     @{
                         @"name": @"A",
                         @"url": @"http://git.example.com/kiwi_themes.git",
                         @"description": @"File templates for the Kiwi testing framework"
                         }],
             @"project_templates": @[
                     @{
                         @"name": @"C",
                         @"url": @"http://git.example.com/cool.git",
                         @"description": @"A plugin for making Xcode ...cool. Very cool."
                         }]
             };
}

ATZPackage *packageWithName(NSArray *packages, NSString *name) {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(ATZPackage *package, NSDictionary *bindings) {
        return [package.name isEqualToString:name];
    }];
    return [packages filteredArrayUsingPredicate:predicate].lastObject;
}



SPEC_BEGIN(ATZPackageFactoryTests)

describe(@"Package Factory", ^{
    
    NSArray *packages = [ATZPackageFactory createPackagesFromDicts:fakeJSON()];
    
    describe(@"creating packages from dictionaries", ^{
        
        it(@"unpacks all types of packages", ^{
            [[@(packages.count) should] equal:@4];
        });
        
        it(@"creates a plugin from a dictionary", ^{
            [[packageWithName(packages, @"D") should] beKindOfClass:[ATZPlugin class]];
        });

        it(@"creates a color scheme from a dictionary", ^{
            [[packageWithName(packages, @"B") should] beKindOfClass:[ATZColorScheme class]];
        });

        it(@"creates a file template from a dictionary", ^{
            [[packageWithName(packages, @"A") should] beKindOfClass:[ATZFileTemplate class]];
        });

        it(@"creates a project template from a dictionary", ^{
            [[packageWithName(packages, @"C") should] beKindOfClass:[ATZProjectTemplate class]];
        });
    });

    it(@"sorts packages by name", ^{
        NSArray *sortedNames = @[@"A", @"B", @"C", @"D"];
        
        NSMutableArray *createdNames = [NSMutableArray new];
        for (ATZPackage *package in packages)
            [createdNames addObject:package.name];
        
        [[createdNames should] equal:sortedNames];
    });

});

SPEC_END
