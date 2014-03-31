//
// ATZPackageTableCellView.m
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

#import "ATZPackageTableCellView.h"
#import "ATZPackage.h"
#import "Alcatraz.h"

#import "ATZInstallButton.h"
#import "ATZPaddedImageButtonCell.h"

@interface ATZPackageTableCellView()
@property (assign) BOOL isHighlighted;
@end

@implementation ATZPackageTableCellView

- (void)awakeFromNib {
    [self createTrackingArea];

    ATZPaddedImageButtonCell *websiteButtonCell = (ATZPaddedImageButtonCell *)[self.websiteButton cell];
    websiteButtonCell.spacingBetweenImageAndText = 3.f; // Plus the original 2 offset, and somehow we're at 7 pixels?! Oh AppKit!
}

- (void)setScreenshotImage:(NSImage *)image isLoading:(BOOL)isLoading animated:(BOOL)animated
{
    BOOL hasImage = nil != image;
    BOOL shouldDisplayWithProperBounds = hasImage || isLoading;

    if (isLoading) {
        [self.screenshotButtonActivityIndicator startAnimation:nil];
    }

    [self setNeedsLayout:YES];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.allowsImplicitAnimation = YES;
        context.duration = animated ? 0.36f : 0.f;

        self.screenshotButtonWidthConstraint.constant = shouldDisplayWithProperBounds ? 48.f : 0.f;
        self.screenshotButtonHeightConstraint.constant = shouldDisplayWithProperBounds ? 48.f : 0.f;
        self.screenshotButtonHorizontalPaddingConstraint.constant = shouldDisplayWithProperBounds ? 14.f : 0.f;

        [self.screenshotButton.animator setAlphaValue:shouldDisplayWithProperBounds ? 1.f:0.f];
        [self.screenshotButton.animator setImage:image];
        [self setNeedsLayout:YES];
    } completionHandler:^{
        [self.screenshotButtonActivityIndicator stopAnimation:nil];
    }];
}

#pragma mark - Private

- (void)createTrackingArea {
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited |
                                                     NSTrackingAssumeInside      | NSTrackingInVisibleRect |
                                                     NSTrackingMouseMoved;
    
    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                     options:focusTrackingAreaOptions
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
}

@end
