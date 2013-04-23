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

#import "Package.h"
#import "Installer.h"

@implementation Package
@dynamic isInstalled, type;

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (!self) return nil;
    
    [self unpackFromDictionary:dict];
    
    return self;
}

- (void)dealloc {
    [self.name release];
    [self.description release];
    [self.remotePath release];
    [super dealloc];
}


#pragma mark - Private

- (void)unpackFromDictionary:(NSDictionary *)dictionary {
    self.name = dictionary[@"name"];
    self.description = dictionary[@"description"];
    self.remotePath = dictionary[@"url"];
}


#pragma mark - Abstract

- (BOOL)isInstalled {
    return [[self installer] isPackageInstalled:self];
}

- (BOOL)requiresRestart {
    @throw [NSException exceptionWithName:@"Not Implemented" reason:@"Some packages don't require restarting!" userInfo:nil];
}

- (void)installWithProgressMessage:(void (^)(NSString *progressMessage))progress completion:(void (^)(NSError *))completion {
    [[self installer] installPackage:self progress:progress completion:completion];
}

- (void)removeWithCompletion:(void (^)(NSError *))completion {
    [[self installer] removePackage:self completion:completion];
}

- (id<Installer>)installer {
    @throw [NSException exceptionWithName:@"Not Implemented" reason:@"Each package has to return a different installer!" userInfo:nil];
}

- (void)setIsInstalled:(BOOL)isInstalled { /* Hack for IB bindings. */ }

@end
