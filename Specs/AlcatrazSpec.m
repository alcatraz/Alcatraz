//
// AlcatrazTests.m
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

#import "Kiwi.h"
#import "Alcatraz.h"
#import "ATZShell.h"
#import "ATZAlcatrazPackage.h"

static NSString *const ALCATRAZ_PATH = @"Library/Application Support/Developer/Shared/Xcode/Plug-ins/Alcatraz.xcplugin";

NSMenu *createFakeMenu() {
    NSMenu *fakeMenu = [[NSMenu alloc] initWithTitle:@"Alcatraz"];
    NSMenuItem *windowMenu = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
    windowMenu.submenu = [[NSMenu alloc] initWithTitle:@"FakeSubmenu"];
    [windowMenu.submenu addItemWithTitle:@"Organizer" action:nil keyEquivalent:@""];
    [windowMenu.submenu addItem:[NSMenuItem separatorItem]];
    [windowMenu.submenu addItemWithTitle:@"Bring All to Front" action:nil keyEquivalent:@""];

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
    __block SEL pluginDidLoad;
    __block SEL initWithBundle;
    
    NSBundle *pluginBundle = [NSBundle bundleWithPath:[NSHomeDirectory() stringByAppendingPathComponent:ALCATRAZ_PATH]];
    
    beforeEach(^{
        [NSApp stub:@selector(mainMenu) andReturn:createFakeMenu()];
        pluginDidLoad = NSSelectorFromString(@"pluginDidLoad:");
        initWithBundle = NSSelectorFromString(@"initWithBundle:");
        
        [pluginBundle loadAndReturnError:&error];
        [pluginBundle.principalClass performSelector:pluginDidLoad withObject:pluginBundle];
        
        if (error) NSLog(@"ZOMG ERRRO! %@", error);
        alcatraz = [[[pluginBundle principalClass] alloc] performSelector:initWithBundle withObject:pluginBundle];
    });
    
    describe(@"loading plugin", ^{
    
        it(@"creates 'Package Manager' menu item under Window submenu", ^{
            NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
            NSMenuItem *alcatrazItem = [[windowMenuItem submenu] itemWithTitle:@"Package Manager"];
            
            [alcatrazItem shouldNotBeNil];
            [[@([windowMenuItem.submenu indexOfItem:alcatrazItem]) should] equal:
              @([windowMenuItem.submenu indexOfItemWithTitle:@"Organizer"] + 1)];
        });
        
        it(@"updates alcatraz", ^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[ATZAlcatrazPackage should] receive:@selector(update)];
                [alcatraz performSelector:initWithBundle withObject:pluginBundle];
            }];
        });
        
    });

    describe(@"pressing the menu item", ^{
        
        context(@"command line tools are available", ^{
            
            it(@"loads alcatraz window and puts it in front", ^{
                [[alcatraz should] receive:@selector(loadWindowAndPutInFront)];
                clickMenuItem();
            });

            it(@"reloads the same window instance after closing", ^{
                clickMenuItem();
                NSWindow *window = [alcatraz.windowController window];
                [window shouldNotBeNil];
                [window performClose:nil];

                clickMenuItem();
                [[[alcatraz.windowController window] should] equal:window];
            });
            
            it(@"tells the window controller to reload packages", ^{
                clickMenuItem();
                [[alcatraz.windowController should] receive:@selector(reloadPackages)];
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
                clickMenuItem();
                [alcatraz.windowController shouldBeNil];
            });
            
            it(@"alerts the user", ^{
                [[mockAlert should] receive:@selector(runModal)];
                clickMenuItem();
            });
        });
    });    
    
});

SPEC_END
