//
//  Alcatraz.m
//  Alcatraz
//
//  Created by Marin Usalj on 4/17/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "Alcatraz.h"

@interface Alcatraz(){}
@property (strong, nonatomic) NSBundle *bundle;
@end

@implementation Alcatraz


+ (void)pluginDidLoad:(NSBundle *)plugin {
    static Alcatraz *sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
        sharedPlugin.bundle = plugin;
    });
}

- (id)init {
    if (self = [super init])
        [self createMenuItem];
    
    return self;
}

- (void)createMenuItem {
    NSMenuItem *viewMenuItem = [[NSApp mainMenu] itemWithTitle:@"View"];
    if (!viewMenuItem) return;
    
    [[viewMenuItem submenu] addItem:[NSMenuItem separatorItem]];

    NSMenuItem *sample = [[NSMenuItem alloc] initWithTitle:@"Plugin Manager" action:@selector(openPluginManagerWindow) keyEquivalent:@""];
    [sample setTarget:self];
    [[viewMenuItem submenu] addItem:sample];
    [sample release];
}

- (void)openPluginManagerWindow
{
    
    NSArray *topLevelObjects;
    [self.bundle loadNibNamed:@"PluginWindow" owner:self topLevelObjects:&topLevelObjects];
    
    NSLog(@"top level objects: %@", topLevelObjects);
    
//    [topLevelObjects[0] makeKeyAndOrderFront:self];
    
//    NSRect frame = NSRectFromCGRect(CGRectMake(200, 200, 500, 500));
//    
//    NSWindow *panel = [[NSWindow alloc] initWithContentRect:frame
//                                                  styleMask:NSUtilityWindowMask | NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask
//                                                    backing:NSBackingStoreBuffered
//                                                      defer:NO];
//    NSTableView *tableView = [[NSTableView alloc] initWithFrame:panel.frame];
//    [panel makeKeyAndOrderFront:self];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end