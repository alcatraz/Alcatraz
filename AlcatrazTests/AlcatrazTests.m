//
//  AlcatrazTests.m
//  AlcatrazTests
//
//  Created by Marin Usalj on 5/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Kiwi.h"
#import "Alcatraz.h"
#import "ATZShell.h"

static NSString *const ALCATRAZ_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin";

NSMenu *createFakeMenu() {
    NSMenu *fakeMenu = [[NSMenu alloc] initWithTitle:@"Alcatraz"];
    NSMenuItem *windowMenu = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
    windowMenu.submenu = [[NSMenu alloc] initWithTitle:@"FakeSubmenu"];
    [windowMenu.submenu addItemWithTitle:@"Organizer" action:nil keyEquivalent:@""];
    
    [fakeMenu addItem:windowMenu];
    return fakeMenu;
}

void clickMenuItem() {
    NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *alcatrazItem = [[windowMenuItem submenu] itemWithTitle:@"Package Manager"];
    [alcatrazItem.target performSelector:alcatrazItem.action];
}

SPEC_BEGIN(AlcatrazTests)

describe(@"Alcatraz.m", ^{
   
    __block Alcatraz *alcatraz;
    __block NSError *error = nil;
    NSBundle *pluginBundle = [NSBundle bundleWithPath:[NSHomeDirectory() stringByAppendingPathComponent:ALCATRAZ_PATH]];
    
    beforeEach(^{
        [NSApp stub:@selector(mainMenu) andReturn:createFakeMenu()];
        
        [pluginBundle loadAndReturnError:&error];
        [[pluginBundle principalClass] performSelector:@selector(pluginDidLoad:) withObject:pluginBundle];
        
        if (error) NSLog(@"ZOMG ERRRO! %@", error);
        alcatraz = [[[pluginBundle principalClass] alloc] performSelector:@selector(initWithBundle:) withObject:pluginBundle];
    });
    
    describe(@"loading plugin", ^{
    
        it(@"creates 'Package Manager' menu item under Window submenu", ^{
            NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
            NSMenuItem *alcatrazItem = [[windowMenuItem submenu] itemWithTitle:@"Package Manager"];
            
            [alcatrazItem shouldNotBeNil];
            [[@([windowMenuItem.submenu indexOfItem:alcatrazItem]) should] equal:@([[windowMenuItem submenu] indexOfItemWithTitle:@"Organizer"] + 1)];
        });
        
    });

    describe(@"pressing the menu item", ^{
        
        context(@"command line tools are available", ^{
            
            it(@"loads alcatraz window and puts it in front", ^{
                [[alcatraz should] receive:@selector(loadWindowAndPutInFront)];
                clickMenuItem();
            });
            
        });
        
        context(@"command line tools are not available", ^{
            
            KWMock *mockAlert = [NSAlert nullMock];
            
            beforeEach(^{
                [NSTask stub:@selector(launchedTaskWithLaunchPath:arguments:) withBlock:^id(NSArray *params) {
                    @throw [NSException exceptionWithName:@"HAI" reason:nil userInfo:nil];
                }];
                [NSAlert stub:@selector(alertWithMessageText:defaultButton:alternateButton:otherButton:informativeTextWithFormat:)
                    andReturn:mockAlert];
            });
            
            it(@"doesn't display the window", ^{
                [[alcatraz shouldNot] receive:@selector(loadWindowAndPutInFront)];
                clickMenuItem();
            });
            
            it(@"alerts the user", ^{
                [[mockAlert should] receive:@selector(runModal)];
                clickMenuItem();
            });
        });
    });    
    
});

SPEC_END
