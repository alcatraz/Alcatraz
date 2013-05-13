// PluginWindowController.m
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

#import "ATZPluginWindowController.h"
#import "ATZDownloader.h"
#import "ATZPackageFactory.h"

#import "ATZDetailItemButton.h"
#import "ATZPackageTableCellView.h"

#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZTemplate.h"
#import "ATZAlcatrazPackage.h"

#import "ATZShell.h"

static NSString *const ALL_ITEMS_ID = @"AllItemsToolbarItem";
static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@)";
static NSString *const SEARCH_AND_CLASS_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@) AND (self isKindOfClass: %@)";

@interface ATZPluginWindowController ()
@property (nonatomic) Class selectedPackageClass;
@property (assign) NSView *hoverButtonsContainer;
@end

@implementation ATZPluginWindowController

- (id)init {
    NSAssert(false, @"Use -initWithNibName:inBundle: to create a new ATZPluginWindowController");
    return self;
}

- (id)initWithBundle:(NSBundle *)bundle {
    if (self = [super init]) {
        _filterPredicate = [NSPredicate predicateWithValue:YES];

        @try {
            [self fetchPlugins];
            [self updateAlcatraz];
            [self setWindow:[self mainWindowInBundle:bundle]];
        }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_packages release];
    [_filterPredicate release];
    
    [super dealloc];
}

- (void)windowDidLoad {
    [[self.window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
}


#pragma mark - Bindings

- (IBAction)checkboxPressed:(NSButton *)checkbox {
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:checkbox]];
    
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
    self.selectedPackageClass = [ATZPlugin class];
    [self updatePredicate];
}

- (IBAction)showOnlyColorSchemes:(id)sender {
    self.selectedPackageClass = [ATZColorScheme class];
    [self updatePredicate];
}

- (IBAction)showOnlyTemplates:(id)sender {
    self.selectedPackageClass = [ATZTemplate class];
    [self updatePredicate];
}

- (IBAction)displayScreenshotPressed:(NSButton *)sender {
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:sender]];
    
    [self displayScreenshot:package.screenshotPath withTitle:package.name];
}

- (IBAction)openPackageWebsitePressed:(NSButton *)sender {
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:sender]];

    [self openWebsite:package.website];
}

- (void)controlTextDidChange:(NSNotification *)note {
    [self updatePredicate];
}

#pragma mark - Private

- (void)removePackage:(ATZPackage *)package andUpdateCheckbox:(NSButton *)checkbox {
    [self showInstallationIndicators];
    
    [package removeWithCompletion:^(NSError *failure) {

        NSString *message = failure ? [NSString stringWithFormat:@"%@ failed to uninstall :( Error: %@", package.name, failure.domain] :
                                      [NSString stringWithFormat:@"%@ uninstalled.", package.name];

        [self flashNotice:message];
        [self reloadUIForPackage:package fromCheckbox:checkbox];
    }];
}

- (void)installPackage:(ATZPackage *)package andUpdateCheckbox:(NSButton *)checkbox {
    [self showInstallationIndicators];
    [package installWithProgressMessage:^(NSString *progressMessage) { self.statusLabel.stringValue = progressMessage; }
                             completion:^(NSError *failure) {
        
        NSString *message = failure ? [NSString stringWithFormat:@"%@ failed to install :( Error: %@", package.name, failure.domain] :
                                      [NSString stringWithFormat:@"%@ installed.", package.name];
        NSLog(@"%@", message);
        [self flashNotice:message];
        [self reloadUIForPackage:package fromCheckbox:checkbox];
    }];
}

- (void)reloadUIForPackage:(ATZPackage *)package fromCheckbox:(NSButton *)checkbox {
    [self hideInstallationIndicators];
    [self reloadCheckbox:checkbox];
    if (package.requiresRestart) [self.restartLabel setHidden:NO];
}

- (void)hideInstallationIndicators {
    [[self progressIndicator] stopAnimation:nil];
    [[self progressIndicator] setHidden:YES];
}

- (void)showInstallationIndicators {
    [[self progressIndicator] setHidden:NO];
    [[self progressIndicator] startAnimation:nil];
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
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadPackageListWithCompletion:^(NSDictionary *packageList, NSError *error) {
        
        if (error) {
            NSLog(@"Error while downloading packages! %@", error);
            [self flashNotice:[NSString stringWithFormat:@"Download failed: %@", error.domain]];
        } else {
            self.packages = [ATZPackageFactory createPackagesFromDicts:packageList];
            [self updatePackages];
        }
        [downloader release];
    }];
}

- (void)updateAlcatraz {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        
        [ATZAlcatrazPackage update];
        [queue release];
    }];
}

- (void)updatePackages {
    for (ATZPackage *package in self.packages) {
        
        if (package.isInstalled) {
            NSOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
                [package updateWithProgressMessage:^(NSString *proggressMessage) {
                    
                    [self flashNotice:proggressMessage];
                    
                } completion:^(NSError *failure) {}];
            }];
            [updateOperation addDependency:[[NSOperationQueue mainQueue] operations].lastObject];
            [[NSOperationQueue mainQueue] addOperation:updateOperation];
        }
    }
}

- (void)flashNotice:(NSString *)notice {
    self.statusLabel.stringValue = notice;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.statusLabel performSelector:@selector(setStringValue:) withObject:@"" afterDelay:3];
    }];
}

- (void)openWebsite:(NSString *)address {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:address]];
}

- (void)displayScreenshot:(NSString *)screenshotPath withTitle:(NSString *)title {
    
    [self.previewPanel.animator setAlphaValue:0.f];
    self.previewPanel.title = title;
    [self retrieveImageViewForScreenshot:screenshotPath completion:^(NSImage *image) {
        
        self.previewImageView.image = image;
        [NSAnimationContext beginGrouping];
        
        [self.previewImageView.animator setFrame:(CGRect){ .origin = CGPointMake(0, 0), .size = image.size }];
        CGRect previewPanelFrame = (CGRect){.origin = self.previewPanel.frame.origin, .size = image.size};
        [self.previewPanel setFrame:previewPanelFrame display:NO animate:YES];
        
        [NSAnimationContext endGrouping];
        
        [self.previewPanel makeKeyAndOrderFront:self];
        [self.previewPanel.animator setAlphaValue:1.f];
        
    }];
}

- (void)retrieveImageViewForScreenshot:(NSString *)screenshotPath completion:(void (^)(NSImage *))completion {
    
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadFileFromPath:screenshotPath completion:^(NSData *responseData, NSError *error) {
    
        NSImage *image = [[NSImage alloc] initWithData:responseData];
        completion(image);
        
        [image release];
        [downloader release];
    }];
    
}

- (NSWindow *) mainWindowInBundle:(NSBundle *)bundle {
    NSArray *nibElements;

#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
    [self.bundle loadNibNamed:@"PluginWindow" owner:windowController topLevelObjects:&nibElements];
#else
    NSNib *nib = [[[NSNib alloc] initWithNibNamed:@"PluginWindow" bundle:bundle] autorelease];
    [nib instantiateNibWithOwner:self topLevelObjects:&nibElements];
#endif

    NSPredicate *windowPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject class] == [NSWindow class];
    }];

    return [nibElements filteredArrayUsingPredicate:windowPredicate][0];
}

@end
