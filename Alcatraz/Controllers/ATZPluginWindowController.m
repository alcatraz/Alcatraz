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
#import "ATZVersionLabel.h"

#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZTemplate.h"

#import "ATZShell.h"
#import "ATZSegmentedCell.h"

static NSString *const ALL_ITEMS_ID = @"AllItemsToolbarItem";
static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@)";
static NSString *const SEARCH_AND_CLASS_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@) AND (self isKindOfClass: %@)";

@interface ATZPluginWindowController ()
@property (nonatomic, assign) Class selectedPackageClass;
@property (nonatomic, assign) NSView *hoverButtonsContainer;
@end

@implementation ATZPluginWindowController

- (id)init {
    @throw [NSException exceptionWithName:@"There's a better initializer" reason:@"Use -initWithNibName:inBundle:" userInfo:nil];
}

- (id)initWithBundle:(NSBundle *)bundle {
    if (self = [super initWithWindowNibName:@"PluginWindow"]) {
        [[self.window toolbar] setSelectedItemIdentifier:ALL_ITEMS_ID];
        
        [self addVersionToWindow];

        _filterPredicate = [NSPredicate predicateWithValue:YES];

        @try {
            if ([NSUserNotificationCenter class])
                [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }
    return self;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self.window makeKeyAndOrderFront:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}


#pragma mark - Bindings

- (IBAction)checkboxPressed:(NSButton *)checkbox {
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:checkbox]];
    
    if (package.isInstalled)
        [self removePackage:package andUpdateCheckbox:checkbox];
    else
        [self installPackage:package andUpdateCheckbox:checkbox];
}

- (IBAction)didClickSegmentedControl:(id)sender {
    NSInteger selectedSegment = [sender selectedSegment];
    NSDictionary *segmentClassMapping = @{@(ATZFilterSegmentColorSchemes): [ATZColorScheme class],
                                          @(ATZFilterSegmentPlugins): [ATZPlugin class],
                                          @(ATZFilterSegmentTemplates): [ATZTemplate class]};
    self.selectedPackageClass = segmentClassMapping[@(selectedSegment)];
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

- (void)keyDown:(NSEvent *)event {
    if (hasPressedCommandF(event))
        [self.window makeFirstResponder:self.searchField];
    else
        [super keyDown:event];
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

        [self flashNotice:message];
        [self reloadUIForPackage:package fromCheckbox:checkbox];
        [self postNotificationForInstalledPackage:package];
    }];
}

- (void)reloadUIForPackage:(ATZPackage *)package fromCheckbox:(NSButton *)checkbox {
    [self hideInstallationIndicators];
    [self reloadCheckbox:checkbox];
    if (package.requiresRestart) [self.restartLabel setHidden:NO];
}

- (void)postNotificationForInstalledPackage:(ATZPackage *)package {
    if (![NSUserNotificationCenter class] || !package.isInstalled || self.window.isKeyWindow) return;
    
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = [NSString stringWithFormat:@"%@ installed", package.type];
    NSString *restartText = package.requiresRestart ? @" Please restart Xcode to use it." : @"";
    notification.informativeText = [NSString stringWithFormat:@"%@ was installed successfully! %@", package.name, restartText];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

BOOL hasPressedCommandF(NSEvent *event) {
    return ([event modifierFlags] & NSCommandKeyMask) && [[event characters] characterAtIndex:0] == 'f';
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
    // TODO: refactor, use compound predicates.

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

- (void)reloadPackages {
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadPackageListWithCompletion:^(NSDictionary *packageList, NSError *error) {
        
        if (error) {
            NSLog(@"Error while downloading packages! %@", error);
            [self flashNotice:[NSString stringWithFormat:@"Download failed: %@", error.domain]];
        } else {
            self.packages = [ATZPackageFactory createPackagesFromDicts:packageList];
            [self updatePackages];
        }
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
    }];

}

- (void)addVersionToWindow {
    NSView *windowFrameView = [[self.window contentView] superview];
    NSTextField *label = [[ATZVersionLabel alloc] initWithFrame:NSMakeRect(self.window.frame.size.width - 38, windowFrameView.bounds.size.height - 26, 30, 20)];
    label.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin | NSViewNotSizable;
    [windowFrameView addSubview:label];
}

@end
