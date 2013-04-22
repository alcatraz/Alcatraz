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

@implementation Git

+ (void)clone:(NSString *)remotePath to:(NSString *)localPath {
    Shell *shell = [Shell new];
    
    [shell executeCommand:@"/usr/bin/git" withArguments:@[@"clone", remotePath, localPath, @"-c push.default=matching"]];
    [shell release];
}

+ (void)updateLocalProject:(NSString *)localPath {
    Shell *shell = [Shell new];

    [shell executeCommand:@"/usr/bin/git" withArguments:@[@"fetch", @"origin"] inWorkingDirectory:localPath];
    [shell executeCommand:@"/usr/bin/git" withArguments:@[@"reset", @"--hard", @"origin/master"] inWorkingDirectory:localPath];
    
    [shell release];
}

@end
