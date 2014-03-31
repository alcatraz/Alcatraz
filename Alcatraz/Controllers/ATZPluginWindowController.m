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

#import "ATZInstallButton.h"

static NSString *const ALL_ITEMS_ID = @"AllItemsToolbarItem";
static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@)";
static NSString *const SEARCH_AND_CLASS_PREDICATE_FORMAT = @"(name contains[cd] %@ OR description contains[cd] %@) AND (self isKindOfClass: %@)";

@interface ATZPluginWindowController ()
@property (nonatomic, assign) Class selectedPackageClass;
@property (nonatomic, assign) NSView *hoverButtonsContainer;

@property (nonatomic, strong) NSCache *rowHeightCache;
@property (nonatomic, strong) ATZPackageTableCellView *samplePackageCellView;
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

        _rowHeightCache = [[NSCache alloc] init];
        _rowHeightCache.countLimit = 1024;

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

- (IBAction)performPackageActivity:(ATZInstallButton *)sender {
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][[self.tableView rowForView:sender]];

    if (package.isInstalled)
        [self removePackage:package andUpdateControl:sender];
    else
        [self installPackage:package andUpdateControl:sender];
}

- (NSDictionary *)segmentClassMapping {
    static NSDictionary *segmentClassMapping;
    if (!segmentClassMapping) {
       segmentClassMapping = @{@(ATZFilterSegmentColorSchemes): [ATZColorScheme class],
            @(ATZFilterSegmentPlugins): [ATZPlugin class],
            @(ATZFilterSegmentTemplates): [ATZTemplate class]};
    }
    return segmentClassMapping;
}

- (IBAction)segmentedControlPressed:(id)sender {
    NSInteger selectedSegment = [sender selectedSegment];
    self.selectedPackageClass = [self segmentClassMapping][@(selectedSegment)];
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

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.packages count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    ATZPackageTableCellView *cell = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:[tableView delegate]];
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][row];

    NSString *websiteButtonTitle = [NSString stringWithFormat:@"%@ / %@", package.username, package.repository];

    [cell.installButton setButtonState:package.isInstalled ? AZTInstallButtonStateInstalled : AZTInstallButtonStateNotInstalled];
    [cell.websiteButton setTitle:websiteButtonTitle];
    [cell.websiteButton setToolTip:package.website];

    [cell.typeImageView setImage:[[NSBundle bundleForClass:[self class]] imageForResource:package.iconName]];

    if (package.screenshotPath.length > 0) {
        [cell setScreenshotImage:nil isLoading:YES animated:YES];

        [self retrieveImageViewForScreenshot:package.screenshotPath progress:nil completion:^(NSImage *screenshotImage) {
            if ([cell.objectValue isEqualTo:package]) {
                [cell setScreenshotImage:screenshotImage isLoading:NO animated:YES];
            }
        }];
    } else {
        [cell setScreenshotImage:nil isLoading:NO animated:NO];
    }

    return cell;
}

#pragma mark - NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    ATZPackage *package = [self.packages filteredArrayUsingPredicate:self.filterPredicate][row];
    NSTableColumn *firstColumn = [tableView.tableColumns firstObject];
    NSString *rowKey = [NSString stringWithFormat:@"%tu-%f", [package hash], firstColumn.width];

    NSNumber *cachedRowHeight = [self.rowHeightCache objectForKey:rowKey];

    if (nil != cachedRowHeight) {
        return [cachedRowHeight floatValue];
    }

    if (nil == self.samplePackageCellView) {
        self.samplePackageCellView = [tableView makeViewWithIdentifier:[firstColumn identifier] owner:[tableView delegate]];
    }

    self.samplePackageCellView.objectValue = package;
    self.samplePackageCellView.bounds = NSMakeRect(0.f, 0.f, firstColumn.width, 98.f);

    [self.samplePackageCellView layoutSubtreeIfNeeded];

    CGFloat rowHeight = [self.samplePackageCellView fittingSize].height;

    [self.rowHeightCache setObject:@(rowHeight) forKey:rowKey];

    return MAX(98.f, rowHeight);
}

- (void)tableViewColumnDidResize:(NSNotification *)notification
{
    NSTableView *tableView = [notification object];
    NSRange rowRange = [tableView rowsInRect:[tableView visibleRect]];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0;
        context.allowsImplicitAnimation = NO;
        [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:rowRange]];
    } completionHandler:nil];
}

#pragma mark - Private

- (void)enqueuePackageUpdate:(ATZPackage *)package {
    if (!package.isInstalled) return;

    NSOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
        [package updateWithProgress:^(NSString *proggressMessage, CGFloat progress){}
                                completion:^(NSError *failure){}];
    }];
    [updateOperation addDependency:[[NSOperationQueue mainQueue] operations].lastObject];
    [[NSOperationQueue mainQueue] addOperation:updateOperation];
}

- (void)removePackage:(ATZPackage *)package andUpdateControl:(ATZInstallButton *)control {
    [control setProgress:0.f animated:YES];
    [package removeWithCompletion:^(NSError *failure) {
        [control setButtonState:AZTInstallButtonStateNotInstalled animated:YES];
    }];
}

- (void)installPackage:(ATZPackage *)package andUpdateControl:(ATZInstallButton *)control {
    [control setButtonState:AZTInstallButtonStateInstalling animated:YES];

    [package installWithProgress:^(NSString *progressMessage, CGFloat progress) {
        [control setProgress:progress animated:YES];
    } completion:^(NSError *failure) {
        [control setProgress:failure ? 0.f : 1.f animated:YES];
        [control setButtonState:failure ? AZTInstallButtonStateError : AZTInstallButtonStateInstalled animated:YES];

        if (package.requiresRestart) {
            [self postNotificationForInstalledPackage:package];
        }
    }];
}

- (void)postNotificationForInstalledPackage:(ATZPackage *)package {
    if (![NSUserNotificationCenter class] || !package.isInstalled) return;
    
    NSUserNotification *notification = [NSUserNotification new];
    notification.title = [NSString stringWithFormat:@"%@ installed", package.type];
    NSString *restartText = package.requiresRestart ? @" Please restart Xcode to use it." : @"";
    notification.informativeText = [NSString stringWithFormat:@"%@ was installed successfully! %@", package.name, restartText];

    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

BOOL hasPressedCommandF(NSEvent *event) {
    return ([event modifierFlags] & NSCommandKeyMask) && [[event characters] characterAtIndex:0] == 'f';
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
        } else {
            self.packages = [ATZPackageFactory createPackagesFromDicts:packageList];
            [self updatePackages];
        }
    }];
}

- (void)updatePackages {
    for (ATZPackage *package in self.packages) {
        [self enqueuePackageUpdate:package];
    }
}

- (void)openWebsite:(NSString *)address {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:address]];
}

- (void)displayScreenshot:(NSString *)screenshotPath withTitle:(NSString *)title {
    
    [self.previewPanel.animator setAlphaValue:0.f];
    self.previewPanel.title = title;
    [self retrieveImageViewForScreenshot:screenshotPath
                                progress:^(CGFloat progress) {

    }
                              completion:^(NSImage *image) {
        
        self.previewImageView.image = image;
        [NSAnimationContext beginGrouping];
        
        [self.previewImageView.animator setFrame:(CGRect){ .origin = CGPointMake(0, 0), .size = image.size }];
        CGRect previewPanelFrame = (CGRect){.origin = self.previewPanel.frame.origin, .size = image.size};
        [self.previewPanel setFrame:previewPanelFrame display:NO animate:NO];
        [self.previewPanel.animator center];
        
        [NSAnimationContext endGrouping];
        
        [self.previewPanel makeKeyAndOrderFront:self];
        [self.previewPanel.animator setAlphaValue:1.f];
    }];
}

- (void)retrieveImageViewForScreenshot:(NSString *)screenshotPath progress:(void (^)(CGFloat))downloadProgress completion:(void (^)(NSImage *))completion {
    
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadFileFromPath:screenshotPath
                            progress:^(CGFloat progress) {
                                if (downloadProgress) {
                                    downloadProgress(progress);
                                }
                            }
                          completion:^(NSData *responseData, NSError *error) {
                              NSImage *image = [[NSImage alloc] initWithData:responseData];

                              if (completion) {
                                  completion(image);
                              }
                          }];
    
}

- (void)addVersionToWindow {
    NSView *windowFrameView = [[self.window contentView] superview];
    NSTextField *label = [[ATZVersionLabel alloc] initWithFrame:(NSRect){
        .origin.x = self.window.frame.size.width - 46,
        .origin.y = windowFrameView.bounds.size.height - 26,
        .size.width = 40,
        .size.height = 20
    }];
    [windowFrameView addSubview:label];
}

@end
