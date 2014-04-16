//
//  Created by Tony Arnold on 31/03/2014.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import "ATZBorderedButtonCell.h"
#import "NSColor+Alcatraz.h"

@implementation ATZBorderedButtonCell

- (id)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];

    if (self) {
        [self p_setupButtonCell];
    }

    return self;
}
- (id)initImageCell:(NSImage *)image
{
    self = [super initImageCell:image];

    if (self) {
        [self p_setupButtonCell];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_setupButtonCell];
    }
    return self;
}

-(BOOL)isOpaque
{
    return NO;
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSRect controlBounds = [controlView bounds];
    NSBezierPath *outerEdgePath = [self p_bezierPathForRect:controlBounds];

    [NSGraphicsContext saveGraphicsState];
    [outerEdgePath addClip];

    [image drawInRect:controlBounds fromRect:NSMakeRect(0, image.size.height - NSHeight(controlBounds), NSWidth(controlBounds), NSHeight(controlBounds)) operation:NSCompositeSourceOver fraction:1.f respectFlipped:YES hints:nil];

    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSBezierPath *outerEdgePath = [self p_bezierPathForRect:frame];

    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

    // Clear the context
    [[NSColor clearColor] set];
    NSRectFillUsingOperation(frame, NSCompositeSourceAtop);

    [ctx saveGraphicsState];

    [outerEdgePath setLineWidth:0.f];

    [self.borderColor set];
    [outerEdgePath stroke];

    [ctx restoreGraphicsState];
}

#pragma mark - Private Methods

- (void)p_setupButtonCell
{
    self.borderColor = [NSColor colorWithCalibratedWhite:0.521 alpha:1.000];
    [self setBackgroundColor:[NSColor whiteColor]];

    [self setButtonType:NSMomentaryLightButton];
    [self setBezelStyle:NSRegularSquareBezelStyle];
    [self setBordered:YES];
    [self setAllowsMixedState:NO];
    [self setTransparent:NO];
}

- (NSBezierPath *)p_bezierPathForRect:(NSRect)frameRect
{
    NSRect insetRect = NSInsetRect(frameRect, 1.f, 1.f);

    NSAffineTransform *transform = [NSAffineTransform transform];
    // build the bezierPath
    [transform translateXBy:0.5 yBy:0.5];

    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRect:insetRect];
    [roundedRect transformUsingAffineTransform:transform];

    return roundedRect;
}

@end
