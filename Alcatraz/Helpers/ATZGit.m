// Git.m
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

#import "ATZGit.h"
#import "ATZShell.h"
#import "NSFileManager+Alcatraz.h"

static NSString *const GIT = @"/usr/bin/git";
static NSString *const IGNORE_PUSH_CONFIG = @"-c push.default=matching";

@implementation ATZGit

+ (void)updateRepository:(NSString *)localPath branchOrTag:(NSDictionary *)resetOptions
              completion:(void(^)(NSString *output, NSError *error))completion {

    [self updateLocalProject:localPath branchOrTag:resetOptions completion:completion];
}

+ (void)cloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath
             completion:(void (^)(NSError *))completion {
    
    [self clone:remotePath to:localPath completion:completion];
}


#pragma mark - Private

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath completion:(void (^)(NSError *))completion {
    ATZShell *shell = [ATZShell new];
    
    [shell executeCommand:GIT withArguments:@[CLONE, remotePath, localPath, IGNORE_PUSH_CONFIG]
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git Clone output: %@", output);
        completion(error);
        [shell release];
    }];
}

// TODO: refactor, make less shell instances (maybe?)
+ (void)updateLocalProject:(NSString *)localPath branchOrTag:(NSDictionary *)options
                completion:(void (^)(NSString *, NSError *))completion {
    
    [self fetch:localPath completion:^(NSString *fetchOutput, NSError *error) {
        
        if (error)
            completion(fetchOutput, error);
        else
            [self resetHard:localPath branchOrTag:options completion:^(NSString *resetOutput, NSError *error) {
                completion(fetchOutput, error);
            }];
    }];
}

+ (void)fetch:(NSString *)localPath completion:(void (^)(NSString *, NSError *))completion {
    
    ATZShell *shell = [ATZShell new];
    [shell executeCommand:GIT withArguments:@[FETCH, ORIGIN] inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git fetch output: %@", output);
        completion(output, error);
        [shell release];
    }];
}

+ (void)resetHard:(NSString *)localPath branchOrTag:(NSDictionary *)options
       completion:(void (^)(NSString *, NSError *))completion {
    
    ATZShell *shell = [ATZShell new];
    NSArray *resetArguments = @[RESET, HARD, options[BRANCH] ?: options[TAG] ?: ORIGIN_MASTER];
    
    [shell executeCommand:GIT withArguments:resetArguments inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git reset output: %@", output);
        completion(output, error);
        [shell release];
    }];
}



@end
