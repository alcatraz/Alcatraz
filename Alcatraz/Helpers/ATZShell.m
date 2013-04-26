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
@property (nonatomic, retain) NSMutableData *taskOutput;
@end

@implementation ATZShell

+ (BOOL)areCommandLineToolsAvailable {
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/git"];
    @try {
        [task launch];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        [task release];
    }
    return YES;
}

- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments completion:(void(^)(NSString *taskOutput, NSError *error))completion {
    [self executeCommand:command withArguments:arguments inWorkingDirectory:nil completion:completion];
}

- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments inWorkingDirectory:(NSString *)path completion:(void(^)(NSString *taskOutput, NSError *error))completion {


    
    NSLog(@"creating task... %@", command);
    
    _taskOutput = [NSMutableData new];
    NSTask *shellTask = [NSTask new];
    NSPipe *outputPipe = [NSPipe new];
    NSPipe *stdErrPipe = [NSPipe new];
    
    if (path) [shellTask setCurrentDirectoryPath:path];
    [shellTask setLaunchPath:command];
    [shellTask setArguments:arguments];
    [shellTask setStandardInput:[NSPipe pipe]];
    [shellTask setStandardOutput:outputPipe];
    [shellTask setStandardError:stdErrPipe];
    
    [self setUpFileHandleForPipe:outputPipe];
    [self setUpFileHandleForPipe:stdErrPipe];
    
    [shellTask setTerminationHandler:^(NSTask *task) {
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"operation completed! main? %@", @([NSThread isMainThread]));
            completion([[NSString alloc] initWithData:self.taskOutput encoding:NSUTF8StringEncoding], nil);
        });
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [shellTask release];
        [_taskOutput release];
        _taskOutput = nil;
    }];
    
    [self tryToLaunchTask:shellTask completionIfFailed:completion];

    

    
}

- (void)thereIsNewShellOutput:(NSNotification *)notification {
    NSData *shellOutput = [[notification.object availableData] copy];
    NSLog(@"new shell output: %@", [[NSString alloc] initWithData:shellOutput encoding:NSUTF8StringEncoding]);
    [self.taskOutput appendData:shellOutput];
    [shellOutput release];
}

#pragma mark - Private

- (void)setUpFileHandleForPipe:(NSPipe *)pipe {
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    [fileHandle waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thereIsNewShellOutput:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:fileHandle];
}

- (void)tryToLaunchTask:(NSTask *)shellTask completionIfFailed:(void(^)(NSString *taskOutput, NSError *error))completion {
    @try {
        NSLog(@"launcing task.. %@ on main %@", shellTask.launchPath, @([NSThread isMainThread]));
//        @synchronized(self) {
            [shellTask launch];
//        }
    }
    @catch (NSException *exception) {
        NSLog(@"Shell command execution failed! %@", exception);
        completion(exception.reason, [NSError errorWithDomain:exception.reason code:667 userInfo:nil]);
    }
}

@end
