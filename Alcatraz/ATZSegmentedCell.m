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

#import "ATZSegmentedCell.h"
#import "NSColor+Alcatraz.h"

static NSInteger const ATZSegmentRoundedMajorVersion = 10;
static NSInteger const ATZSegmentRoundedMinorVersion = 9;

static CGFloat const ATZSegmentsVerticalPadding = 1.f;
static CGFloat const ATZSegmentsHorizontalPadding = 6.f;

@implementation ATZSegmentedCell

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self updateAllSegmentsWidth];
    }
    return self;
}

- (instancetype)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self) {
        [self updateAllSegmentsWidth];
    }
    return self;
}

- (instancetype)initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];
    if (self) {
        [self updateAllSegmentsWidth];
    }
    return self;
}

#pragma mark - Custom drawing

- (void)_drawBackgroundWithFrame:(NSRect)frame inView:(NSView *)controlView {
    return;
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    NSString* text = [self labelForSegment:segment];
    NSMutableDictionary* attributes = [[self defaultAttributes] mutableCopy];
    NSRect backgroundRect = [self labelBackgroundFrameForSegment:segment inFrame:frame];

    // Draw the blue background if the segment is selected
    if ([self isSelectedForSegment:segment]) {
        attributes[NSForegroundColorAttributeName] = [NSColor whiteColor];

        CGFloat cornerRadius = [self shouldUseRoundedPillStyle] ? floorf(backgroundRect.size.height/2) : 4;
        NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:backgroundRect xRadius:cornerRadius yRadius:cornerRadius];
        [[NSColor selectedItemColor] setFill];
        [backgroundPath fill];
    }

    // Draw the text centered
    [text drawInRect:backgroundRect withAttributes:attributes];

}

#pragma mark - Overring getters and setters

- (void)setLabel:(NSString *)label forSegment:(NSInteger)segment {
    [super setLabel:label forSegment:segment];

    CGFloat width = [self widthForSegmentLabel:label];
    [self setWidth:width forSegment:segment];
}

#pragma mark - Private methods

- (NSDictionary*)defaultAttributes {
    NSFont* font = [NSFont fontWithName:@"HelveticaNeue" size:11.f];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];

    return @{
             NSFontAttributeName: font,
             NSParagraphStyleAttributeName: style,
             NSKernAttributeName: @(0.3)
             };
}

- (NSRect)labelBackgroundFrameForSegment:(NSInteger)segment inFrame:(NSRect)frame {
    NSString* text = [self labelForSegment:segment];
    NSMutableDictionary* attributes = [[self defaultAttributes] mutableCopy];
    CGSize labelSize = [text sizeWithAttributes:attributes];
    CGFloat verticalInset = (frame.size.height - labelSize.height) / 2 - ATZSegmentsVerticalPadding;

    return CGRectInset(frame, 0, verticalInset);
}

- (void)updateAllSegmentsWidth {
    for (NSInteger segment = 0; segment < self.segmentCount; segment++) {
        NSString *label = [self labelForSegment:segment];
        CGFloat width = [self widthForSegmentLabel:label];
        [self setWidth:width forSegment:segment];
    }
}

- (CGFloat)widthForSegmentLabel:(NSString *)label {
    return [self widthForSegmentLabel:label withAttributes:[self defaultAttributes]];
}

- (CGFloat)widthForSegmentLabel:(NSString *)label withAttributes:(NSDictionary*)attributes {
    NSSize textSize = [label boundingRectWithSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesDeviceMetrics attributes:attributes].size;
    return textSize.width + 2 * ATZSegmentsHorizontalPadding;
}

- (BOOL)shouldUseRoundedPillStyle {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return version.majorVersion <= ATZSegmentRoundedMajorVersion
    && version.minorVersion <= ATZSegmentRoundedMinorVersion;
}

@end
