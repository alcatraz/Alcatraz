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

@implementation ATZGit


+ (void)updateOrCloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath {

    if ([[NSFileManager sharedManager] fileExistsAtPath:localPath])
        [self updateLocalProject:localPath];
    
    else [self clone:remotePath to:localPath];
}


#pragma mark - Private

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath {
    ATZShell *shell = [ATZShell new];
    
    [shell executeCommand:GIT withArguments:@[@"clone", remotePath, localPath, @"-c push.default=matching"]
               completion:^(NSString *output) {
                   
        NSLog(@"ATZGit Clone output: %@", output);
        [shell release];
    }];
}

// TODO: Decide wether the API should be synchronous or asynchronous. ATM, it's mixed and that's bad.
+ (void)updateLocalProject:(NSString *)localPath {
    ATZShell *shell = [ATZShell new];
    
    [shell executeCommand:GIT withArguments:@[@"fetch", @"origin"] inWorkingDirectory:localPath
               completion:^(NSString *output) {
                   
        NSLog(@"ATZGit fetch output: %@", output);
    }];
    
    [shell executeCommand:GIT withArguments:@[@"reset", @"--hard", @"origin/master"] inWorkingDirectory:localPath
               completion:^(NSString *output) {
                   
        NSLog(@"ATZGit reset output: %@", output);
        [shell release];
    }];

}


@end
