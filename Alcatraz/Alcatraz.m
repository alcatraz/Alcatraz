// Alcatraz.m
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


#import "Alcatraz.h"
#import "Downloader.h"
#import "Package.h"
#import "PackageFactory.h"

@interface Alcatraz(){}
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, retain) NSArray *packages;
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
        self.bundle = [plugin retain];
        [self createMenuItem];
        
        @try { [self fetchPlugins]; }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.bundle release];
    [self.packages release];
    [super dealloc];
}


#pragma mark - Private

- (void)fetchPlugins {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    Downloader *downloader = [Downloader new];
    downloader.bundle = self.bundle;
    [downloader downloadPackageListAnd:^(NSDictionary *packageList) {
        
        self.packages = [PackageFactory createPackagesFromDicts:packageList];
    }
    failure:^(NSError *error) {
       NSLog(@"Error while downloading packages! %@", error);
    }];
    
    [downloader release];
    [pool drain];
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

#pragma mark - TableView delegate

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Package *package = self.packages[row];
    
    if ([[tableColumn.headerCell title] isEqualToString:@"Name"])
        return package.name;

    else if ([[tableColumn.headerCell title] isEqualToString:@"Type"])
        return package.type;
    
    else if ([[tableColumn.headerCell title] isEqualToString:@"Description"])
        return package.description;

    return @(package.isInstalled);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.packages.count;
}




@end
