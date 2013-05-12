// Alcatraz.m
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


#import "Alcatraz.h"
#import "ATZPluginWindowController.h"
#import "ATZPluginInstaller.h"
#import "ATZPlugin.h"
#import "ATZShell.h"

@interface Alcatraz(){}
@property (nonatomic, retain) NSBundle *bundle;
@end

@implementation Alcatraz

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static Alcatraz *sharedPlugin;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    });
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;
        [self createMenuItem];        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_bundle release];
    [super dealloc];
}

#pragma mark - Private

- (void)createMenuItem {
    NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *pluginManagerItem = [[NSMenuItem alloc] initWithTitle:@"Package Manager"
                                                               action:@selector(checkForCMDLineToolsAndOpenWindow)
                                                        keyEquivalent:@"9"];
    pluginManagerItem.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask;
    pluginManagerItem.target = self;
    [windowMenuItem.submenu insertItem:pluginManagerItem
                               atIndex:[windowMenuItem.submenu indexOfItemWithTitle:@"Organizer"] + 1];
    [pluginManagerItem release];
}

- (void)checkForCMDLineToolsAndOpenWindow {
    
    if ([ATZShell areCommandLineToolsAvailable])
        [self loadWindowAndPutInFront];
    else
        [self presentAlertForInstallingCMDLineTools];
}

- (void)loadWindowAndPutInFront {
    NSArray *nibElements;
    
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
    [self.bundle loadNibNamed:@"PluginWindow" owner:[ATZPluginWindowController new] topLevelObjects:&nibElements];
#else
    NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"PluginWindow" bundle:self.bundle] autorelease];
    [nib instantiateNibWithOwner:[[ATZPluginWindowController new] autorelease] topLevelObjects:&nibElements];
#endif
    
    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class] == [NSWindow class];
    }];
    
    NSWindow *window = [nibElements filteredArrayUsingPredicate:windowPredicate][0];
    [window makeKeyAndOrderFront:self];
}

- (void)presentAlertForInstallingCMDLineTools {
    NSAlert *alert = [NSAlert alertWithMessageText:
@"Xcode Command Line Tools are not currently installed, and are required to run Alcatraz. \
Command Line Tools are available for installation in the Downloads section of Preferences."
                                     defaultButton:nil
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    [alert runModal];
}


@end
