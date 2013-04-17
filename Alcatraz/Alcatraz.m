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
    NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *pluginManagerItem = [[NSMenuItem alloc] initWithTitle:@"Plugin Manager"
                                                               action:@selector(openPluginManagerWindow)
                                                        keyEquivalent:@"P"];
    pluginManagerItem.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask;
    pluginManagerItem.target = self;
    [windowMenuItem.submenu insertItem:pluginManagerItem
                               atIndex:[windowMenuItem.submenu indexOfItemWithTitle:@"Organizer"] + 1];
    [pluginManagerItem release];
}

- (void)openPluginManagerWindow {
    
    NSArray *nibElements;
    [self.bundle loadNibNamed:@"PluginWindow" owner:self topLevelObjects:&nibElements];
    
    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class] == [NSWindow class];
    }];
    NSWindow *window = [nibElements filteredArrayUsingPredicate:windowPredicate][0];
    [window makeKeyAndOrderFront:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - TableView delegate

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return @[@"Marin",
             @"Ivana",
             @"Petra",
             @"Marin",
             @"Marin"
             ][row];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 5;
}




@end