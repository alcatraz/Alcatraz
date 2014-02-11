//
//  main.c
//  Alcatraz Commandline Tool
//
//  Created by Boris Bügling on 11.02.14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import "ATZCommandlineAppDelegate.h"

int main(int argc, const char * argv[])
{
    ATZCommandlineAppDelegate* appDelegate = [ATZCommandlineAppDelegate new];
    
    NSApplication* app = [NSApplication sharedApplication];
    app.delegate = appDelegate;
    
    [NSApp run];
    return 0;
}

