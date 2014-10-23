//
//  AppDelegate.m
//  AlcatrazMenuItem
//
//  Created by John Holdsworth on 23/10/2014.
//  Copyright (c) 2014 John Holdsworth. All rights reserved.
//

#import "AppDelegate.h"
#import "ATZPluginWindowController.h"

@interface AppDelegate ()

@property ATZPluginWindowController *windowController;
@property NSStatusItem *statusItem;
@property NSImage *menuIcon;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.statusItem = [[NSStatusBar systemStatusBar]
                  statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setEnabled:YES];
    [self.statusItem setToolTip:@"Alcatraz"];

    [self.statusItem setAction:@selector(showPackageManager:)];
    [self.statusItem setTarget:self];

    // Title as Image
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"ATZIcon" ofType:@"tif"];
    self.menuIcon = [[NSImage alloc] initWithContentsOfFile:path];
    [self.statusItem setImage:self.menuIcon];
    [self.statusItem setTitle:@""];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)showPackageManager:(id)sender
{
    if (!self.windowController)
        self.windowController = [[ATZPluginWindowController alloc] initWithBundle:[NSBundle bundleForClass:self.class]];

    [[self.windowController window] makeKeyAndOrderFront:self];
    [self.windowController reloadPackages];
}

@end
