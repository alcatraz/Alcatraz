// ATZTitleButton.m
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

#import "ATZDetailItemButton.h"

#define MIN_ALPHA 0.5f

@implementation ATZDetailItemButton

- (void)mouseEntered:(NSEvent *)theEvent {
    self.alphaValue = 0.8f;
}

- (void)mouseExited:(NSEvent *)theEvent {
    self.alphaValue = MIN_ALPHA;
}

- (void)resetCursorRects {
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}


- (void)awakeFromNib {
    self.alphaValue = MIN_ALPHA;
    [self createTrackingArea];
}


#pragma mark - Private

- (void)createTrackingArea {
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited |
                                                     NSTrackingAssumeInside      | NSTrackingInVisibleRect;

    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                     options:focusTrackingAreaOptions owner:self userInfo:nil];
    [self addTrackingArea:focusTrackingArea];
    [focusTrackingArea release];
}

@end
