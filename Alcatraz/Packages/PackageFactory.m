// PackageFactory.m
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

#import "PackageFactory.h"
#import "Plugin.h"
#import "ColorScheme.h"
#import "ProjectTemplate.h"
#import "FileTemplate.h"

@implementation PackageFactory

+ (NSArray *)createPackagesFromDicts:(NSDictionary *)packagesInDicts {
    NSMutableArray *packages = [NSMutableArray new];
    
    for (NSDictionary *pluginDict in packagesInDicts[@"plugins"]) {
        Plugin *plugin = [[Plugin alloc] initWithDictionary:pluginDict];
        [packages addObject:plugin];
        [plugin release];
    }
    for (NSDictionary *templateDict in packagesInDicts[@"project_templates"]) {
        Template *template = [[ProjectTemplate alloc] initWithDictionary:templateDict];
        [packages addObject:template];
        [template release];
    }
    for (NSDictionary *templateDict in packagesInDicts[@"file_templates"]) {
        Template *template = [[FileTemplate alloc] initWithDictionary:templateDict];
        [packages addObject:template];
        [template release];
    }
    for (NSDictionary *colorSchemeDict in packagesInDicts[@"color_schemes"]) {
        ColorScheme *colorScheme = [[ColorScheme alloc] initWithDictionary:colorSchemeDict];
        [packages addObject:colorScheme];
        [colorScheme release];
    }

    return [packages autorelease];
}

@end
