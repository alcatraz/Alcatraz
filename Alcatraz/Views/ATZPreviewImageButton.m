//
// ATZPreviewImageButton.m
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

#import "ATZPreviewImageButton.h"

CGFloat const ATZPreviewImageHeight = 200.f;

@interface ATZPreviewImageButton ()
@property (nonatomic, getter=isFullSize) BOOL fullSize;
@end

@implementation ATZPreviewImageButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setWantsLayer:YES];
        [self.layer setCornerRadius:4.f];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderColor:[NSColor colorWithWhite:0.9 alpha:1.f].CGColor];
        [self.layer setBorderWidth:1.f];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (!self.image)
        return;
    NSSize imageSize = self.image.size;
    CGFloat x, y, width, height;
    if (imageSize.width >= self.bounds.size.width) {
        width = imageSize.width;
        height = imageSize.height;
    } else {
        width = self.bounds.size.width;
        height = (width/imageSize.width) * imageSize.height;
    }
    x = (self.bounds.size.width - width)/2;
    y = (ATZPreviewImageHeight - height)/2;
    NSRect imageRect = NSMakeRect(x, y, width, height);
    [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeDestinationAtop
                  fraction:1.f respectFlipped:YES hints:nil];
}

- (NSSize)intrinsicContentSize {
    if (self.image || [self isFullSize])
        return NSMakeSize(self.bounds.size.width, ATZPreviewImageHeight);

    return NSZeroSize;
}

- (void)setImage:(NSImage *)image {
    [image lockFocusFlipped:YES];
    [super setImage:image];
}

@end
