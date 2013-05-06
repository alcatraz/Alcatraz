// Package.m
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

#import "ATZPackage.h"
#import "ATZInstaller.h"

@implementation ATZPackage
@dynamic isInstalled, type, website, extension;

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (!self) return nil;
    
    [self unpackFromDictionary:dict];
    
    return self;
}

- (void)dealloc {
    [_name release];
    [_description release];
    [_remotePath release];
    [_screenshotPath release];
    [super dealloc];
}


#pragma mark - Private

- (void)unpackFromDictionary:(NSDictionary *)dictionary {
    self.name = dictionary[@"name"];
    self.description = dictionary[@"description"];
    self.remotePath = dictionary[@"url"];
    self.screenshotPath = dictionary[@"screenshot"];
}

- (NSString *)projectPathFromRawPath:(NSString *)rawURL {
    NSString *username = rawURL.pathComponents[2];
    NSString *repository = rawURL.pathComponents[3];
    return [NSString stringWithFormat:@"https://github.com/%@/%@", username, repository];
}

#pragma mark - Property getters

- (NSString *)website {
    if ([self.remotePath rangeOfString:@"raw.github.com"].location != NSNotFound)
        return [self projectPathFromRawPath:self.remotePath];
    
    else return self.remotePath;
}


#pragma mark - Abstract

- (BOOL)isInstalled {
    return [[self installer] isPackageInstalled:self];
}

- (BOOL)requiresRestart {
    @throw [NSException exceptionWithName:@"Not Implemented" reason:@"Some packages don't require restarting!" userInfo:nil];
}

- (void)installWithProgressMessage:(void (^)(NSString *))progress completion:(void (^)(NSError *))completion {
    [[self installer] installPackage:self progress:progress completion:completion];
}

- (void)updateWithProgressMessage:(void (^)(NSString *))progress completion:(void (^)(NSError *))completion {
    [[self installer] updatePackage:self progress:progress completion:completion];
}

- (void)removeWithCompletion:(void (^)(NSError *))completion {
    [[self installer] removePackage:self completion:completion];
}

- (ATZInstaller *)installer {
    @throw [NSException exceptionWithName:@"Not Implemented" reason:@"Each package has a different installer!" userInfo:nil];
}

- (NSString *)extension {
    @throw [NSException exceptionWithName:@"Not Implemented" reason:@"Each package has a different extension!" userInfo:nil];
}

- (void)setIsInstalled:(BOOL)isInstalled { /* Hack for IB bindings. */ }

@end
