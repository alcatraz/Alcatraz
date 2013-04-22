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
#import "PackageFactory.h"

#import "Plugin.h"
#import "ColorScheme.h"
#import "Template.h"

static NSString *const ALL_ITEMS_ID = @"AllItemsToolbarItem";
static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@)";
static NSString *const SEARCH_AND_CLASS_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@) AND (self isKindOfClass: %@)";

@interface PluginWindowController()
@property (nonatomic) Class selectedPackageClass;
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
    [self.filterPredicate release];
    [super dealloc];
}

- (void)windowDidLoad {
    [[self.window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
}

#pragma mark - Bindings

- (IBAction)checkboxPressed:(NSButton *)checkbox {
    Package *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:checkbox]];
    
    if (package.isInstalled)
        [self removePackage:package andUpdateCheckbox:checkbox];
    else
        [self installPackage:package andUpdateCheckbox:checkbox];
}

- (IBAction)showAllPackages:(id)sender {
    self.selectedPackageClass = nil;
    [self updatePredicate];
}

- (IBAction)showOnlyPlugins:(id)sender {
    self.selectedPackageClass = [Plugin class];
    [self updatePredicate];
}

- (IBAction)showOnlyColorSchemes:(id)sender {
    self.selectedPackageClass = [ColorScheme class];
    [self updatePredicate];
}

- (IBAction)showOnlyTemplates:(id)sender {
    self.selectedPackageClass = [Template class];
    [self updatePredicate];
}

- (void)controlTextDidChange:(NSNotification *)note {
    [self updatePredicate];
}

#pragma mark - Private

- (void)removePackage:(Package *)package andUpdateCheckbox:(NSButton *)checkbox {
    [package removeWithCompletion:^(NSError *failure) {

        if (failure) NSLog(@"Package failed to uninstall! %@", failure);
        else         NSLog(@"Package uninstalled! %@", package.name);

        [self reloadCheckbox:checkbox];
    }];
}

- (void)installPackage:(Package *)package andUpdateCheckbox:(NSButton *)checkbox {
    NSLog(@"Installing package... %@", package.name);
    [package installWithProgress:^(CGFloat progress){} completion:^(NSError *failure) {
        
        if (failure) NSLog(@"Package failed to install :( %@", failure);
        else         NSLog(@"Package installed! %@", package.name);
        
        [self reloadCheckbox:checkbox];
    }];
}

- (void)reloadCheckbox:(NSButton *)checkbox {
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.tableView rowForView:checkbox]]
                              columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)updatePredicate {
    NSString *searchText = self.searchField.stringValue;    
    // filter by type and search field text
    if (self.selectedPackageClass && searchText.length > 0) {
        self.filterPredicate = [NSPredicate predicateWithFormat:SEARCH_AND_CLASS_PREDICATE_FORMAT, searchText, searchText, self.selectedPackageClass];
        
        // filter by type
    } else if (self.selectedPackageClass) {
        self.filterPredicate = [NSPredicate predicateWithFormat:CLASS_PREDICATE_FORMAT, self.selectedPackageClass];
        
        // filter by search field text
    } else if (searchText.length > 0) {
        self.filterPredicate = [NSPredicate predicateWithFormat:SEARCH_PREDICATE_FORMAT, searchText, searchText];
        
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

@end
