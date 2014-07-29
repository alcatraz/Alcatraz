//
// ATZPackageTableCellView.m
//
// Copyright (c) 2013 Marin Usalj | supermar.in
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

@interface ATZPackageTableCellView()
@property (assign) BOOL isHighlighted;
@end

@implementation ATZPackageTableCellView

- (void)awakeFromNib {
    [self.buttonsContainerView setWantsLayer:YES];
    [self createTrackingArea];
}

- (void)setButtonsHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    float alphaValue = highlighted ? 1.0f : 0.0f;

    id buttonsContainerView = animated ? self.buttonsContainerView.animator : self.buttonsContainerView;

    [buttonsContainerView setAlphaValue: alphaValue];
}

- (void)viewWillDraw {
    [self showScreenshotButtonIfNeeded];
    [self.websiteButton setToolTip:[(ATZPackage *)self.objectValue website]];
    [self setButtonsHighlighted:self.isHighlighted animated:NO];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self showButtonsIfNeeded];
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.isHighlighted = NO;
    [self setButtonsHighlighted:NO animated:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (!self.isHighlighted)
        [self showButtonsIfNeeded];
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

- (void)showButtonsIfNeeded {
    NSPoint globalLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = [self.window convertScreenToBase:globalLocation];
    NSPoint viewLocation = [self convertPoint:windowLocation fromView:nil];
    if (NSPointInRect(viewLocation, self.bounds)) {
        [self setButtonsHighlighted:YES animated:YES];
    }
}

- (void)showScreenshotButtonIfNeeded {
    CGRect websiteButtonFrame = self.websiteButton.frame;
    if (![(ATZPackage *)self.objectValue screenshotPath]) {
        [self.screenshotButton setHidden:YES];
        websiteButtonFrame.origin.y = self.frame.size.height / 2 - websiteButtonFrame.size.height;
    } else {
        websiteButtonFrame.origin.y = (self.frame.size.height - websiteButtonFrame.size.height) / 2;
        [self.screenshotButton setHidden:NO];
    }
    self.websiteButton.frame = websiteButtonFrame;
}

@end
