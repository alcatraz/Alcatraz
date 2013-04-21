// PluginWindowController.m
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

#import "PluginWindowController.h"
#import "Downloader.h"
#import "Package.h"
#import "PackageFactory.h"

#define ALL_ITEMS_ID  @"AllItemsToolbarItem"
static int const PLUGIN_TAG   = 325;
static int const SCHEME_TAG   = 326;
static int const TEMPLATE_TAG = 327;

@interface PluginWindowController()
@property (nonatomic, retain) NSString *selectedPackageType;
@end

@implementation PluginWindowController

- (id)init {
    if (self = [super init]) {
        self.filterPredicate = [NSPredicate predicateWithValue:YES];
        @try { [self fetchPlugins]; }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }
    return self;
}

- (void)dealloc {
    [self.packages release];
    [self.selectedPackageType release];
    [self.filterPredicate release];
    [super dealloc];
}

- (IBAction)filterPackagesByType:(id)sender {
    switch ([sender tag]) {
        case PLUGIN_TAG:   self.selectedPackageType = @"Plugin";       break;
        case SCHEME_TAG:   self.selectedPackageType = @"Color Scheme"; break;
        case TEMPLATE_TAG: self.selectedPackageType = @"Template";     break;
            
        default: self.selectedPackageType = nil;
    }
    [self updatePredicate];
}

- (IBAction)checkboxPressed:(NSButton *)checkbox {

    Package *package = self.packages[[self.tableView rowForView:checkbox]];
    
    if (package.isInstalled)
        [self removePackage:package andUpdateCheckbox:checkbox];
    else
        [self installPackage:package andUpdateCheckbox:checkbox];
}

- (void)removePackage:(Package *)package andUpdateCheckbox:(NSButton *)checkbox {
    [package removeAnd:^{
        
        NSLog(@"Package uninstalled! %@", package.name);
    } failure:^(NSError *error) {
        
        NSLog(@"Package failed to uninstall! %@", package.name);
    }];
}

- (void)installPackage:(Package *)package andUpdateCheckbox:(NSButton *)checkbox {
    [package installWithProgress:^(CGFloat progress) {
        
    } completion:^{
        NSLog(@"Package installed! %@", package.name);
        
    } failure:^(NSError *error) {
        NSLog(@"Package failed to install! %@", package.name);
    }];
}

- (void)controlTextDidChange:(NSNotification *) note {
    [self updatePredicate];
}

- (void)updatePredicate {
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
    }
     failure:^(NSError *error) {
        NSLog(@"Error while downloading packages! %@", error);
    }];
    [downloader release];
    [pool drain];
}

- (void)windowDidLoad {
    [[self.window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
}

@end
