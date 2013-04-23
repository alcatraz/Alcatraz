// Shell.m
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

#import "ATZShell.h"

@interface ATZShell (){}
@property (strong, nonatomic) NSMutableData *taskOutput;
@end

@implementation ATZShell

- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments {
    [self executeCommand:command withArguments:arguments completion:^(NSString *output){}];
}
- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments inWorkingDirectory:(NSString *)path {
    [self executeCommand:command withArguments:arguments inWorkingDirectory:path completion:^(NSString *output){}];
}
- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments completion:(void(^)(NSString *taskOutput))completion {
    [self executeCommand:command withArguments:arguments inWorkingDirectory:nil completion:completion];
}

- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments inWorkingDirectory:(NSString *)path completion:(void(^)(NSString *taskOutput))completion {
    _taskOutput = [NSMutableData new];
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *stdErrPipe = [NSPipe pipe];
    NSTask *shellTask = [NSTask new];
 
    if (path) [shellTask setCurrentDirectoryPath:path];
    [shellTask setLaunchPath:command];
    [shellTask setArguments:arguments];
    [shellTask setStandardOutput:outputPipe];
    [shellTask setTerminationHandler:^(NSTask *task) {
        completion([[[NSString alloc] initWithData:self.taskOutput encoding:NSUTF8StringEncoding] autorelease]);
    }];
    [shellTask setStandardError:stdErrPipe];
    [self setUpFileHandleForPipe:outputPipe];
    [self setUpFileHandleForPipe:stdErrPipe];
    
    [self tryToLaunchTask:shellTask];

    [shellTask release];
    [self.taskOutput release];
}

- (void)thereIsNewShellOutput:(NSNotification *)notification {

    [self.taskOutput appendData:[notification.object availableData]];
}

#pragma mark - Private

- (void)setUpFileHandleForPipe:(NSPipe *)pipe {
    [[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thereIsNewShellOutput:)
                                                 name:NSFileHandleDataAvailableNotification object:nil];
}

- (void)tryToLaunchTask:(NSTask *)shellTask {
    @try {
        [shellTask launch];
        [shellTask waitUntilExit];
    }
    @catch (NSException *exception) { NSLog(@"Shell command execution failed! %@", exception); }
}

@end
