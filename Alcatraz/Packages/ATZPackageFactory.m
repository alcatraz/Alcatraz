// PackageFactory.m
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

#import "ATZPackageFactory.h"
#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZProjectTemplate.h"
#import "ATZFileTemplate.h"

@implementation ATZPackageFactory

static NSDictionary *packageClasses;

+ (void)initialize {
    packageClasses = @{
        @"plugins": [ATZPlugin class],
        @"color_schemes": [ATZColorScheme class],
        @"project_templates": [ATZProjectTemplate class],
        @"file_templates": [ATZFileTemplate class]
    };
}

+ (NSArray *)createPackagesFromDicts:(NSDictionary *)packagesInDicts {
    NSMutableArray *packages = [NSMutableArray array];
    @autoreleasepool {
        for (NSString *packageType in packagesInDicts.allKeys) {

            for (NSDictionary *packageDict in packagesInDicts[packageType]) {
                ATZPackage *package = [[packageClasses[packageType] alloc] initWithDictionary:packageDict];
                [packages addObject:package];
            }

        }
    }
    return [self sortPackagesByName:packages];
}

+ (NSArray *)sortPackagesByName:(NSArray *)unsortedPackages {
    return [unsortedPackages sortedArrayUsingComparator:^(ATZPackage *first, ATZPackage *second) {
        return [first.name caseInsensitiveCompare:second.name];
    }];
}

@end

