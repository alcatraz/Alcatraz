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
    if (self = [super init]) {
        _filterPredicate = [NSPredicate predicateWithValue:YES];
        
        @try { [self fetchPlugins]; [self updateAlcatraz]; }
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
        NSLog(@"Operations: %@", @([[NSOperationQueue mainQueue] operations].count));
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

- (void)resizeImage:(NSImageView *)imageView {
    const CGFloat maxSize = 800.0f;
    NSSize imageSize = imageView.image.size;
    
    if (imageSize.height > maxSize || imageSize.width > maxSize) {
        CGFloat aspectRatio = imageSize.height / imageSize.width;
        
        CGSize newImageSize;
        if (aspectRatio > 1.0) {
            newImageSize = CGSizeMake(maxSize / aspectRatio, maxSize);
        } else if (aspectRatio < 1.0) {
            newImageSize = CGSizeMake(maxSize, maxSize * aspectRatio);
        } else {
            newImageSize = CGSizeMake(maxSize, maxSize);
        }
        [imageView.image setSize:NSSizeFromCGSize(newImageSize)];
    }
}

- (void)displayScreenshot:(NSString *)screenshotPath withTitle:(NSString *)title {
    NSImageView *imageView = [self imageViewForScreenshot:screenshotPath];
    
    [self resizeImage:imageView];
    
    CGRect frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
    NSWindow* window  = [[NSWindow alloc] initWithContentRect:frame
                                                    styleMask:NSTitledWindowMask | NSClosableWindowMask
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
    [window setContentView:imageView];
    [window center];
    [window setTitle:title];
    
    NSWindowController *windowController = [[[NSWindowController alloc] init] autorelease];
    [windowController setWindow:window];
    [windowController showWindow:self];
    [window release];
}

- (NSImageView *)imageViewForScreenshot:(NSString *)screenshotPath {
    NSURL *screenshotURL = [NSURL URLWithString:screenshotPath];
    NSData *imageData = [NSData dataWithContentsOfURL:screenshotURL];
    
    NSImage *image = [[NSImage alloc] initWithData:imageData];
    NSImageView *imageView = [[[NSImageView alloc] init] autorelease];
    
    [imageView setImage:image];
    [image release];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    return imageView;
}

@end
