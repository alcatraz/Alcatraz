//
// ATZPackageTableViewDelegate.m
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

#import "Alcatraz.h"
#import "ATZPackageTableViewDelegate.h"
#import "ATZPackageListTableCellView.h"
#import "ATZFillableButton.h"
#import "ATZPreviewImageButton.h"
#import "ATZPackage.h"
#import "ATZPlugin.h"
#import "ATZTemplate.h"
#import "ATZColorScheme.h"
#import "ATZDownloader.h"
#import "NSColor+Alcatraz.h"

@interface ATZPackageTableViewDelegate ()

@property (nonatomic, weak) id tableViewOwner;
@property (nonatomic, strong) NSArray* filteredPackages;
@end

@implementation ATZPackageTableViewDelegate

static NSString* const packageCellIdentifier = @"ATZPackageListCellIdentifier";
static CGFloat const ATZPackageCellSummaryOffset = 130.f;
static CGFloat const ATZPackageCellBaseHeight = 116.f;

- (instancetype)initWithPackages:(NSArray*)packages tableViewOwner:(id)owner {
    if (self = [super init]) {
        _packages = packages;
        _tableViewOwner = owner;
    }
    return self;
}

- (void)configureTableView:(NSTableView *)tableView {
    NSNib* nib = [[NSNib alloc] initWithNibNamed:NSStringFromClass([ATZPackageListTableCellView class]) bundle:[Alcatraz sharedPlugin].bundle];
    [tableView registerNib:nib forIdentifier:packageCellIdentifier];
}

- (void)filterUsingPredicate:(NSPredicate*)predicate {
    if (predicate) {
        self.filteredPackages = [self.packages filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredPackages = self.packages;
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.filteredPackages.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return self.filteredPackages[row];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    ATZPackage* package = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    ATZPackageListTableCellView* view = [tableView makeViewWithIdentifier:packageCellIdentifier owner:self.tableViewOwner];
    [view.titleField setStringValue:package.name];
    [view.descriptionField setStringValue:package.summary];
    [view.linkButton setImage:[self tableView:tableView websiteImageForTableColumn:tableColumn row:row]];
    [view.linkButton setTitle:[self tableView:tableView displayWebsiteForTableColumn:tableColumn row:row]];
    [view.installButton setTitle:([package isInstalled] ? @"REMOVE" : @"INSTALL")];
    BOOL hasImage = package.screenshotPath != nil;
    [view.previewButton setFullSize:hasImage];
    [view.previewButton setHidden:!hasImage];
    
    if (package.screenshotPath) {
        [view.previewButton setImage:[self cachedImageForPackage:package]];
        if (!view.previewButton.image) {
            __weak typeof(tableView) weakTableView = tableView;
            [self fetchAndCacheImageForPackage:package progress:NULL completion:^(NSImage *image) {
                [weakTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                [weakTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
            }];
        }
    } else {
        [view.previewButton setImage:nil];
    }
    
    ATZFillableButton* installButton = (ATZFillableButton*)view.installButton;
    [installButton setButtonBorderStyle:ATZFillableButtonTypeInstall];
    [installButton setFillRatio:([package isInstalled] ? 100 : 0) animated:NO];

    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    ATZPackage* package = [self tableView:tableView objectValueForTableColumn:nil row:row];
    CGFloat height = ATZPackageCellBaseHeight;
    NSSize summarySize = NSMakeSize(tableView.bounds.size.width - ATZPackageCellSummaryOffset, CGFLOAT_MAX);
    NSDictionary* textAttributes = @{NSFontAttributeName : [NSFont fontWithName:@"HelveticaNeue" size:13.f]};
    NSStringDrawingOptions options = (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading);
    height += ceilf([package.summary boundingRectWithSize:summarySize options:options attributes:textAttributes].size.height);
    if (package.screenshotPath)
        height += ATZPreviewImageHeight;
    return height;
}

#pragma mark - Package Configuration

- (NSString*)tableView:(NSTableView*)tableView displayWebsiteForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row {
    ATZPackage* package = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    switch (package.websiteType) {
        case ATZPackageWebsiteTypeBitbucket:
        case ATZPackageWebsiteTypeGithub: {
            NSString *username = package.website.pathComponents[2];
            NSString *repository = package.website.pathComponents[3];
            return [NSString stringWithFormat:@"%@/%@", username, repository];
        }

        default:
            return package.website;
    }
}

- (NSImage *)tableView:(NSTableView*)tableView websiteImageForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString* websiteImageName = nil;
    ATZPackage* package = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    switch (package.websiteType) {
        case ATZPackageWebsiteTypeGithub:
            websiteImageName = @"github_grayscale";
            break;
        case ATZPackageWebsiteTypeBitbucket:
            websiteImageName = @"bitbucket_grayscale";
            break;
        case ATZPackageWebsiteTypeOtherGit:
        default:
            websiteImageName = @"git_grayscale";
            break;
    }
    return [[Alcatraz sharedPlugin].bundle imageForResource:websiteImageName];
}

#pragma mark - Image Previews

- (NSCache *)imageCache {
    static NSCache* cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    return cache;
}

- (NSImage *)cachedImageForPackage:(ATZPackage *)package {
    return [[self imageCache] objectForKey:package.name];
}

- (void)cacheImage:(NSImage *)image forPackage:(ATZPackage *)package {
    [[self imageCache] setObject:image forKey:package.name];
}

- (void)fetchAndCacheImageForPackage:(ATZPackage*)package progress:(void(^)(CGFloat))progress completion:(void(^)(NSImage *))completion {
    
    NSImage *image = [self cachedImageForPackage:package];
    
    if(image) {
        if(completion) {
            completion(image);
        }
        return;
    }
    
    ATZDownloader *downloader = [ATZDownloader new];
    [downloader downloadFileFromPath:package.screenshotPath
                            progress:progress
                          completion:^(NSData *responseData, NSError *error) {
                              if (error)
                                  return;

                              NSImage *image = [[NSImage alloc] initWithData:responseData];
                              if (!image)
                                  return;
                              
                              [self cacheImage:image forPackage:package];
                              if (completion)
                                  completion(image);
                          }];
}

@end
