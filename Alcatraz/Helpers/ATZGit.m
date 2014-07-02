// Git.m
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

#import "ATZGit.h"
#import "ATZShell.h"
#import "NSFileManager+Alcatraz.h"

@implementation ATZGit

+ (void)updateRepository:(NSString *)localPath revision:(NSString *)revision
                                             completion:(void(^)(NSString *output, NSError *error))completion {

    NSLog(@"Updating Repo: %@", localPath);
    [self updateLocalProject:localPath revision:revision completion:completion];
}

+ (void)cloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath
                                                completion:(void (^)(NSString *output, NSError *))completion {

    NSLog(@"Cloning Repo: %@", localPath);
    [self clone:remotePath to:localPath completion:completion];
}

+ (NSString *)parseRevisionFromDictionary:(NSDictionary *)dict {
    return
        dict[BRANCH] ? [ORIGIN stringByAppendingPathComponent:dict[BRANCH]] :
        dict[TAG]    ?:
        dict[COMMIT] ?: nil;
}

+ (BOOL)areCommandLineToolsAvailable {
    BOOL areAvailable = YES;
    @try {
        [NSTask launchedTaskWithLaunchPath:@"/usr/bin/git" arguments:@[@"--version"]];
    }
    @catch (NSException *exception) {
        areAvailable = NO;
    }
    return areAvailable;
}

#pragma mark - Private

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath completion:(void (^)(NSString *, NSError *))completion {
    ATZShell *shell = [ATZShell new];
    
    [shell executeCommand:GIT withArguments:@[CLONE, remotePath, localPath, IGNORE_PUSH_CONFIG]
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git Clone output: %@", output);
        completion(output, error);
    }];
}

// TODO: refactor, make less shell instances (maybe?)
+ (void)updateLocalProject:(NSString *)localPath revision:(NSString *)revision
                completion:(void (^)(NSString *, NSError *))completion {
    
    [self fetch:localPath completion:^(NSString *fetchOutput, NSError *error) {
        
        if (error)
            completion(fetchOutput, error);
        else
            [self resetHard:localPath revision:revision completion:^(NSString *resetOutput, NSError *error) {
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
    }];
}

+ (void)resetHard:(NSString *)localPath revision:(NSString *)revision
       completion:(void (^)(NSString *, NSError *))completion {
    
    ATZShell *shell = [ATZShell new];
    NSArray *resetArguments = @[RESET, HARD, revision ?: ORIGIN_MASTER];
    
    [shell executeCommand:GIT withArguments:resetArguments inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git reset output: %@", output);
        completion(output, error);
    }];
}



@end
