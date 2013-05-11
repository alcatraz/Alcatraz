//
//  AlcatrazTests.m
//  AlcatrazTests
//
//  Created by Marin Usalj on 5/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Kiwi.h"

SPEC_BEGIN(AlcatrazTests)

describe(@"Loading plugin", ^{
   
    it(@"creates 'Package Manager' menu item under Window submenu", ^{
       
        
        
        NSString *ALCATRAZ_PATH = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin"];
        
        
        
        NSBundle *pluginBundle = [NSBundle bundleWithPath:ALCATRAZ_PATH];
        
        NSLog(@"WAS IT LOADED? %@", @([pluginBundle isLoaded]));
        
        NSError *error = nil;
        [pluginBundle loadAndReturnError:&error];
        [[pluginBundle principalClass] performSelector:@selector(pluginDidLoad:) withObject:pluginBundle];
        if (error)
            NSLog(@"ZOMG ERRRO! %@", error);
        
        NSLog(@"WAS IT LOADED AFTER? %@", @([pluginBundle isLoaded]));
        
        
        NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
        
        
        NSMenuItem *alcatrazItem = [[windowMenuItem submenu] itemWithTitle:@"Package Manager"];
        NSLog(@"APP: %@ , BUNDLE: %@ MENU: %@", [NSApplication sharedApplication] , [NSBundle mainBundle], [NSApp mainMenu]);
        [alcatrazItem shouldNotBeNil];
        
        [[@([windowMenuItem.submenu indexOfItem:alcatrazItem]) should] equal:@([[windowMenuItem submenu] indexOfItemWithTitle:@"Organizer"] + 1)];
    });
    
});

SPEC_END
