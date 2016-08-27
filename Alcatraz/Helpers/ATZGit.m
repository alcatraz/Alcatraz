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
    return [self gitExecutablePath] != nil;
}

+ (NSString *)gitExecutablePath {
    static dispatch_once_t onceToken;
    static NSString *gitPath;
    dispatch_once(&onceToken, ^{
        NSArray *gitPathOptions = @[
            @"/usr/bin/git",
            @"/usr/local/bin/git"
        ];
        for (NSString *path in gitPathOptions) {
            @try {
                [NSTask launchedTaskWithLaunchPath:path arguments:@[@"--version"]];
            }
            @catch (NSException *exception) {
                continue;
            }
            gitPath = path;
            break;
        }
    });
    return gitPath;
}

#pragma mark - Private

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath completion:(void (^)(NSString *, NSError *))completion {
    ATZShell *shell = [ATZShell new];

    [shell executeCommand:[self gitExecutablePath] withArguments:@[CLONE, RECURSIVE, remotePath, localPath, IGNORE_PUSH_CONFIG]
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git Clone output: %@", output);
        completion(output, error);
    }];
}

/// This will:
/// - fetch new commits from the remote;
/// - hard reset HEAD to `revision`;
/// - update submodules to match what the superproject expects at `revision`
// TODO: refactor, make less shell instances (maybe?)
+ (void)updateLocalProject:(NSString *)localPath revision:(NSString *)revision
                completion:(void (^)(NSString *, NSError *))completion {
    
    [self fetch:localPath completion:^(NSString *fetchOutput, NSError *error) {
        if (error) {
            completion(fetchOutput, error);
            return;
        }

        [self resetHard:localPath revision:revision completion:^(NSString *resetOutput, NSError *error) {
            if (error) {
                completion(resetOutput, error);
                return;
            }

            [self submoduleUpdate:localPath completion:^(NSString *submoduleUpdateOutput, NSError *error) {
                if (error) {
                    completion(submoduleUpdateOutput, error);
                    return;
                }

                completion(fetchOutput, error);
            }];
        }];
    }];
}

+ (void)fetch:(NSString *)localPath completion:(void (^)(NSString *, NSError *))completion {
    
    ATZShell *shell = [ATZShell new];
    [shell executeCommand:[self gitExecutablePath] withArguments:@[FETCH, RECURSE_SUBMODULES_ON_DEMAND, ORIGIN] inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git fetch output: %@", output);
        completion(output, error);
    }];
}

+ (void)resetHard:(NSString *)localPath revision:(NSString *)revision
       completion:(void (^)(NSString *, NSError *))completion {
    
    ATZShell *shell = [ATZShell new];
    NSArray *resetArguments = @[RESET, HARD, revision ?: ORIGIN_MASTER];

    [shell executeCommand:[self gitExecutablePath] withArguments:resetArguments inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {
                   
        NSLog(@"Git reset output: %@", output);
        completion(output, error);
    }];
}

+ (void)submoduleUpdate:(NSString *)localPath completion:(void (^)(NSString *, NSError *))completion {

    ATZShell *shell = [ATZShell new];

    [shell executeCommand:[self gitExecutablePath] withArguments:@[SUBMODULE, UPDATE] inWorkingDirectory:localPath
               completion:^(NSString *output, NSError *error) {

       NSLog(@"Git submodule update output: %@", output);
       completion(output, error);
   }];
}



@end
