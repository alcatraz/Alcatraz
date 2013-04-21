// Shell.m
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

#import "Shell.h"

@interface Shell(){}
@property (nonatomic, retain) NSFileHandle *fileHandle;
@end

@implementation Shell

- (void)dealloc {
    [self.fileHandle release];
    [super dealloc];
}

- (void)executeCommand:(NSString *)command withArguments:(NSArray *)arguments {
    NSPipe *pipe = [NSPipe pipe];
    NSTask *shellTask = [NSTask new];
    [shellTask setLaunchPath:command];
    [shellTask setArguments:arguments];
    [shellTask setStandardOutput:pipe];
    
    self.fileHandle = [pipe fileHandleForReading];
    [self.fileHandle waitForDataInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thereIsNewShellOutput:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:nil];
    
    [shellTask setTerminationHandler:^(NSTask *task) {
        NSLog(@"Shell task terminated! %@ %@", command, arguments);
//        NSLog(@"Leftover from file handle: %@", [self.fileHandle read]);
        [task release];
    }];
    NSLog(@"Launching Shell task! %@ %@", command, arguments);
    [shellTask launch];
}

- (void)thereIsNewShellOutput:(NSNotification *)notification {
    NSLog(@"New shell output! %@", notification.debugDescription);
    NSData *data = nil;
    while ((data = [self.fileHandle availableData]) && [data length]){
        NSLog(@"HA! %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    }
}

#pragma mark - Private



@end
