// TemplateInstaller.m
//
// Copyright (c) 2013 mneorr.com
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


#import "TemplateInstaller.h"
#import "Template.h"
#import "Git.h"

@implementation TemplateInstaller

#pragma mark - Public

- (void)installPackage:(Template *)package progress:(void (^)(CGFloat))progress
            completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {

    [Git updateOrCloneRepository:package.remotePath toLocalPath:[self pathForClonedPackage:package]];
    [self copyTemplatesToXcode:package completion:completion failure:failure];
}

- (void)removePackage:(Template *)package
           completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {

    [[NSFileManager sharedManager] removeItemAtPath:[self pathForInstalledPackage:package] completion:completion failure:failure];
}

- (BOOL)isPackageInstalled:(Package *)package {
    
    return [[NSFileManager sharedManager] fileExistsAtPath:[self pathForInstalledPackage:package]];
}

#pragma mark - Private

- (NSString *)pathForClonedPackage:(Package *)package {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:package.name];
}

- (NSString *)pathForInstalledPackage:(Package *)package {
    @throw [NSException exceptionWithName:@"Abstract TemplateInstaller" reason:@"Install path needs to be overriden in subclasses" userInfo:nil];
}

- (void)copyTemplatesToXcode:(Template *)template completion:(void (^)(void))completion failure:(void (^)(NSError *))failure {
    NSError *error = nil;
    
    [[NSFileManager sharedManager] createDirectoryAtPath:[self pathForInstalledPackage:template]
                             withIntermediateDirectories:YES attributes:nil error:&error];
    
    for (NSString *templatePath in [self templateFilesFromClonedDirectory:[self pathForClonedPackage:template]]) {

        NSString *templateFileName = [templatePath componentsSeparatedByString:@"/"].lastObject;
        NSString *installPath = [[self pathForInstalledPackage:template] stringByAppendingPathComponent:templateFileName];
        
        [[NSFileManager sharedManager] copyItemAtPath:templatePath toPath:installPath error:&error];
    }
    
    error ? failure(error) : completion();
}

- (NSArray *)templateFilesFromClonedDirectory:(NSString *)clonePath {
    NSMutableArray *foundTemplates = [NSMutableArray new];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    @try {
        NSDirectoryEnumerator *enumerator = [[NSFileManager sharedManager] enumeratorAtPath:clonePath];
        NSString *directoryEntry;
        
        while (directoryEntry = [enumerator nextObject]) {
            if ([directoryEntry hasSuffix:@".xctemplate"])
                [foundTemplates addObject:[clonePath stringByAppendingPathComponent:directoryEntry]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"shit.. %@", exception);
    }
    [pool drain];
    return [foundTemplates autorelease];
}

@end
