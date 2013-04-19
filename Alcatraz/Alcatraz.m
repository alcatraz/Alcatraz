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

#define ALL_ITEMS_ID  @"AllItemsToolbarItem"
#define PLUGIN_TAG    325
#define SCHEME_TAG    326
#define TEMPLATE_TAG  327

@interface Alcatraz(){}
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, retain) NSString *selectedPackageType;
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
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
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
    [self.selectedPackageType release];
    [self.filterPredicate release];
    [super dealloc];
}

- (IBAction)filterPackagesByType:(id)sender {
    NSLog(@"Filter by %ld", (long)[sender tag]);
    switch ([sender tag]) {
        case PLUGIN_TAG:   self.selectedPackageType = @"Plugin";       break;
        case SCHEME_TAG:   self.selectedPackageType = @"Color Scheme"; break;
        case TEMPLATE_TAG: self.selectedPackageType = @"Template";     break;

        default: self.selectedPackageType = nil;
    }
    [self updatePredicate];
}

- (void) controlTextDidChange:(NSNotification *) note {
    [self updatePredicate];
}

#pragma mark - Private

- (void) updatePredicate {
    NSString *searchText = self.searchField.stringValue;

    // filter by type and search field text
    if (self.selectedPackageType && searchText.length > 0) {
        self.filterPredicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@ OR description contains[cd] %@) AND (type = %@)", searchText, searchText, self.selectedPackageType];

    // filter by type
    } else if (self.selectedPackageType) {
        self.filterPredicate = [NSPredicate predicateWithFormat:@"(type = %@)", self.selectedPackageType];

    // filter by search field text
    } else if (searchText.length > 0) {
        self.filterPredicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@ OR description contains[cd] %@)", searchText, searchText];

    // show all
    } else {
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
    }
}

- (void)fetchPlugins {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    Downloader *downloader = [Downloader new];
    [downloader downloadPackageListAnd:^(NSDictionary *packageList) {
        
        self.packages = [PackageFactory createPackagesFromDicts:packageList];
        for (Package *package in self.packages) {
            NSLog(@"Package: %@ is installed? %@", package.name, @(package.isInstalled));
            if ([package.name isEqualToString:@"OMMiniXcode"])
                [package installWithProgress:^(CGFloat progress) {
                    
                } completion:^{
                   NSLog(@"installed!!!! \0/ %@", package.name);
                } failure:^(NSError *error) {
                    NSLog(@"failed to install :( %@", package.name);
                }];
        }
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
    [[window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
}

@end
