// PluginWindowController.m
//
// Copyright (c) 2014 Marin Usalj | supermar.in
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

#import <Cocoa/Cocoa.h>

#import "ATZPluginWindowController.h"
#import "ATZDownloader.h"
#import "Alcatraz.h"
#import "ATZPackageFactory.h"
#import "ATZStyleKit.h"
#import "ATZCache.h"

#import "ATZPlugin.h"
#import "ATZColorScheme.h"
#import "ATZTemplate.h"

#import "ATZShell.h"

#import "ATZFillableButton.h"
#import "ATZPackageTableViewDelegate.h"

static NSString *const CLASS_PREDICATE_FORMAT = @"(self isKindOfClass: %@)";
static NSString *const SEARCH_PREDICATE_FORMAT = @"(name contains[cd] %@ OR summary contains[cd] %@)";
static NSString *const INSTALLED_PREDICATE_FORMAT = @"(installed == YES)";
static NSString *const BLACKLISTED_PREDICATE_FORMAT = @"(blacklisted == YES)";

typedef NS_ENUM(NSInteger, ATZFilterSegment) {
    ATZFilterSegmentPlugins = 0,
    ATZFilterSegmentColorSchemes = 1,
    ATZFilterSegmentTemplates = 2,
};

@interface ATZPluginWindowController ()
@property (nonatomic, assign) NSView *hoverButtonsContainer;
@property (nonatomic, strong) ATZPackageTableViewDelegate* tableViewDelegate;
@end

@implementation ATZPluginWindowController

- (id)init {
    @throw [NSException exceptionWithName:@"There's a better initializer" reason:@"Use -initWithNibName:inBundle:" userInfo:nil];
}

- (id)initWithBundle:(NSBundle *)bundle {
    if (self = [super initWithWindowNibName:NSStringFromClass([ATZPluginWindowController class])]) {
        @try {
            if ([NSUserNotificationCenter class])
                [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        }
        @catch(NSException *exception) { NSLog(@"I've heard you like exceptions... %@", exception); }
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self addVersionToWindow];
    if ([self.window respondsToSelector:@selector(setTitleVisibility:)])
        self.window.titleVisibility = NSWindowTitleHidden;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    [self.window makeKeyAndOrderFront:self];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - Bindings

- (IBAction)installPressed:(ATZFillableButton *)button {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:button]];

    if (package.isInstalled) {
        if (package.isBlacklisted) {
            [self whitelistPackage:(ATZPlugin *)package andUpdateControl:button];
        }
        else {
            [self removePackage:package andUpdateControl:button];
        }
    }
    else {
        [self installPackage:package andUpdateControl:button];
    }

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

- (IBAction)segmentedControlPressed:(NSSegmentedControl*)sender {
    [self updatePredicate];
}

- (IBAction)displayScreenshotPressed:(NSButton *)sender {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:sender]];
    [self displayScreenshotForPackage:package];
}

- (IBAction)openPackageWebsitePressed:(NSButton *)sender {
    ATZPackage *package = [self.tableViewDelegate tableView:self.tableView objectValueForTableColumn:0 row:[self.tableView rowForView:sender]];

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

- (IBAction)reloadPackages:(id)sender {
    if (!self.packages) {
        // No packages loaded yet, display from cache in the meantime
        NSDictionary *packageList = [ATZCache loadPackagesFromCache];
        [self displayPackages:packageList];
    }

    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadPackageListWithCompletion:^(NSDictionary *packageList, NSError *error) {

        if (error) {
            NSLog(@"Error while downloading packages! %@", error);
        } else {
            [self displayPackages:packageList];
            [ATZCache cachePackages:packageList];
            [self updatePackages];
        }
    }];
}

- (void)displayPackages:(NSDictionary *)packageList {
    self.packages = [ATZPackageFactory createPackagesFromDicts:packageList];
    [self reloadTableView];
}

- (IBAction)updatePackageRepoPath:(id)sender {
    // present dialog with text field, update repo path, redownload package list
    NSAlert *alert = [NSAlert new];
    alert.messageText = [Alcatraz localizedStringForKey:@"change-path.message"];
    [alert addButtonWithTitle:[Alcatraz localizedStringForKey:@"actions.save"]];
    [alert addButtonWithTitle:[Alcatraz localizedStringForKey:@"actions.cancel"]];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 500, 24)];
    input.stringValue = [ATZDownloader packageRepoPath];
    alert.accessoryView = input;

    if ([alert runModal] == NSAlertFirstButtonReturn && ![input.stringValue isEqualToString:[ATZDownloader packageRepoPath]]) {
        [ATZDownloader setPackagesRepoPath:input.stringValue];
        [self reloadPackages:nil];
    }
}

- (IBAction)resetPackageRepoPath:(id)sender {
    [ATZDownloader resetPackageRepoPath];
    [self reloadPackages:nil];
}

- (void)reloadTableView {
    if (!self.tableViewDelegate) {
        self.tableViewDelegate = [[ATZPackageTableViewDelegate alloc] initWithPackages:self.packages
                                                                        tableViewOwner:self];
        self.tableView.delegate = self.tableViewDelegate;
        self.tableView.dataSource = self.tableViewDelegate;

        [self.tableViewDelegate configureTableView:self.tableView];
    }
    else {
        [self.tableViewDelegate updatePackages:self.packages];
    }
    
    [self updatePredicate];
}

#pragma mark - Private

- (void)enqueuePackageUpdate:(ATZPackage *)package {
    if (!package.isInstalled) return;

    NSOperation *updateOperation = [NSBlockOperation blockOperationWithBlock:^{
        [package updateWithProgress:^(NSString *progressMessage, CGFloat progress){}
                         completion:^(NSError *failure){}];
    }];
    [updateOperation addDependency:[[NSOperationQueue mainQueue] operations].lastObject];
    [[NSOperationQueue mainQueue] addOperation:updateOperation];
}

- (void)removePackage:(ATZPackage *)package andUpdateControl:(ATZFillableButton *)button {
    [package removeWithCompletion:^(NSError *failure) {
        [ATZStyleKit updateButton:button forPackageState:package animated:YES];
    }];
}

- (void)installPackage:(ATZPackage *)package andUpdateControl:(ATZFillableButton *)button {
    [package installWithProgress:^(NSString *progressMessage, CGFloat progress) {
        button.title = @"INSTALLING";
        [button setFillRatio:progress animated:YES];
    } completion:^(NSError *failure) {
        [ATZStyleKit updateButton:button forPackageState:package animated:YES];
        if (package.requiresRestart) {
            [self postNotificationForInstalledPackage:package];
        }
    }];
}

- (void)whitelistPackage:(ATZPlugin *)package andUpdateControl:(ATZFillableButton *)button {
    [package whitelistWithCompletion:^(NSError *failure) {
        [ATZStyleKit updateButton:button forPackageState:package animated:YES];
        [self updateInstallationStateSegmentedControl];
        if (package.requiresRestart) [self postNotificationForInstalledPackage:package];
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

- (void)updatePackages {
    for (ATZPackage *package in self.packages) {
        [self enqueuePackageUpdate:package];
    }
    [self updateInstallationStateSegmentedControl];
}

- (void)openWebsite:(NSString *)address {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:address]];
}

- (void)displayScreenshotForPackage:(ATZPackage *)package {

    [self.previewPanel.animator setAlphaValue:0.f];
    self.previewPanel.title = package.name;

    [self.tableViewDelegate fetchAndCacheImageForPackage:package progress:NULL completion:^(NSImage *image) {
        [self displayImage:image withTitle:package.name];
    }];
}

- (void)displayImage:(NSImage *)image withTitle:(NSString*)title {
    self.previewImageView.image = image;
    [NSAnimationContext beginGrouping];

    [self.previewImageView.animator setFrame:(CGRect){ .origin = CGPointMake(0, 0), .size = image.size }];
    CGRect previewPanelFrame = (CGRect){.origin = self.previewPanel.frame.origin, .size = image.size};
    [self.previewPanel setFrame:previewPanelFrame display:NO animate:NO];
    [self.previewPanel.animator center];

    [NSAnimationContext endGrouping];

    [self.previewPanel makeKeyAndOrderFront:self];
    [self.previewPanel.animator setAlphaValue:1.f];
}

- (void)addVersionToWindow {
    self.versionTextField.stringValue = [[[Alcatraz sharedPlugin] bundle] infoDictionary][@"CFBundleShortVersionString"];
}

#pragma mark - Packages filtering

- (void)updateInstallationStateSegmentedControl {
    NSPredicate *blacklistedPredicate = [NSPredicate predicateWithFormat:BLACKLISTED_PREDICATE_FORMAT];
    NSUInteger blacklistedPackagesCount = [self.packages filteredArrayUsingPredicate:blacklistedPredicate].count;

    if (blacklistedPackagesCount > 0) {
        [self.installationStateSegmentedControl setSegmentCount:3];
        NSString *label = [NSString stringWithFormat:@"Blocked (%lu)", blacklistedPackagesCount];
        [self.installationStateSegmentedControl setLabel:label forSegment:2];
    }
    else {
        [self.installationStateSegmentedControl setSegmentCount:2];
        [self.installationStateSegmentedControl setSelectedSegment:0];
        [self updatePredicate];
    }
}

- (void)updatePredicate {
    NSString *searchText = self.searchField.stringValue;
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithCapacity:3];
    Class selectedPackageClass = [self segmentClassMapping][@([self.packageTypeSegmentedControl selectedSegment])];
    if (selectedPackageClass) {
        [predicates addObject:[NSPredicate predicateWithFormat:CLASS_PREDICATE_FORMAT, selectedPackageClass]];
    }

    if (searchText.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:SEARCH_PREDICATE_FORMAT, searchText, searchText]];
    }

    if ([self.installationStateSegmentedControl selectedSegment] == 1) {
        [predicates addObject:[NSPredicate predicateWithFormat:INSTALLED_PREDICATE_FORMAT]];
    }
    else if ([self.installationStateSegmentedControl selectedSegment] == 2) {
        [predicates addObject:[NSPredicate predicateWithFormat:BLACKLISTED_PREDICATE_FORMAT]];
    }

    [self.tableViewDelegate filterUsingPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    [self.tableView reloadData];
}

@end
