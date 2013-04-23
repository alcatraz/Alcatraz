// Git.m
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

#import "Git.h"
#import "Shell.h"
#import "NSFileManager+Alcatraz.h"

static NSString *const GIT = @"/usr/bin/git";
static NSString *const CLONE = @"clone";
static NSString *const IGNORE_GITCONFIG = @"-c push.default=matching";
static NSString *const FETCH_ORIGIN = @"fetch origin";
static NSString *const RESET_ARGS = @"reset --hard origin/master";

@implementation Git

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath {
    Shell *shell = [Shell new];
    
    [shell executeCommand:GIT withArguments:@[CLONE, remotePath, localPath, IGNORE_GITCONFIG]];
    [shell release];
}

+ (void)updateLocalProject:(NSString *)localPath {
    Shell *shell = [Shell new];

    [shell executeCommand:GIT withArguments:@[FETCH_ORIGIN] inWorkingDirectory:localPath];
    [shell executeCommand:GIT withArguments:@[RESET_ARGS] inWorkingDirectory:localPath];
    
    [shell release];
}

+ (void)updateOrCloneRepository:(NSString *)remotePath toLocalPath:(NSString *)localPath {

    if ([[NSFileManager sharedManager] fileExistsAtPath:localPath])
        [self updateLocalProject:localPath];
    
    else [self clone:remotePath to:localPath];
}

@end
