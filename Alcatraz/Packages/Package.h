// Package.h
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

#import <Foundation/Foundation.h>

@protocol Installer;


@interface Package :NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *remotePath;
@property (nonatomic, readonly) BOOL isInstalled;
@property (nonatomic, readonly) BOOL requiresRestart;

- (id)initWithDictionary:(NSDictionary *)dict;

- (void)installWithProgressMessage:(void(^)(NSString *proggressMessage))progress
                        completion:(void(^)(NSError *failure))completion;

- (void)removeWithCompletion:(void(^)(NSError *failure))completion;


/// To be overriden in subclasses. Each type of package has a different installer.
#pragma mark - Abstract

- (id<Installer>)installer;

@end
