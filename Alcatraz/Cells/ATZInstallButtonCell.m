//
//  Created by Tony Arnold on 30/03/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import "ATZInstallButtonCell.h"
#import "NSColor+Alcatraz.h"

static const CGFloat BUTTON_CORNER_RADIUS = 3.f;

@implementation ATZInstallButtonCell

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

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView*)controlView
{
    NSBezierPath *outerClip = [self p_bezierPathForRect:frame];

    NSColor *backgroundColor;
    NSColor *borderColor;

    if (AZTInstallButtonCellStateInstalling == self.buttonCellState) {
        backgroundColor = self.backgroundColor;
        borderColor = [NSColor blackColor];
    } else if ([self isHighlighted]) {
        backgroundColor = self.highlightBackgroundColor;
        borderColor = self.highlightBorderColor;
    } else if (self.hover) {
        backgroundColor = self.hoverBackgroundColor;
        borderColor = self.hoverBorderColor;
    } else if (NO == [self isEnabled]) {
        backgroundColor = self.disabledBackgroundColor;
        borderColor = self.disabledTextColor;
    } else {
        backgroundColor = self.backgroundColor;
        borderColor = self.borderColor;
    }

    NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

    // Clear the context
    [[NSColor clearColor] set];
    NSRectFillUsingOperation(frame, NSCompositeSourceAtop);

    [ctx saveGraphicsState];

    [outerClip setLineWidth:0.f];
    [backgroundColor setFill];
    [outerClip fill];

    if (AZTInstallButtonCellStateInstalling == self.buttonCellState) {
        [ctx saveGraphicsState];
        NSBezierPath *innerClip = [self p_bezierPathForRect:frame];

        [innerClip addClip];

        NSRect progressFillRect = NSZeroRect;
        NSRect progressEmptyRect = NSZeroRect;
        NSDivideRect(frame, &progressFillRect, &progressEmptyRect, NSWidth(frame) * self.progress, NSMinXEdge);

        [self.highlightBackgroundColor set];
        NSRectFillUsingOperation(progressFillRect, NSCompositeSourceAtop);

        [ctx restoreGraphicsState];
    }

    [borderColor set];
    [outerClip stroke];

    [ctx restoreGraphicsState];
}

- (NSSize)cellSizeForBounds:(NSRect)aRect
{
    NSSize cellSizeForBounds = [super cellSizeForBounds:aRect];

    cellSizeForBounds.width -= 12.f;
    cellSizeForBounds.height -= 6.f;

    return cellSizeForBounds;
}

- (NSRect)titleRectForBounds:(NSRect)theRect
{
    NSRect modifiedRect = theRect;

    modifiedRect.origin.y += 1.f;

    return modifiedRect;
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSAttributedString *newTitle;
    NSColor *textColor;

    if (AZTInstallButtonCellStateInstalling == self.buttonCellState) {
        textColor = [NSColor clearColor];
    } else if ([self isHighlighted]) {
        textColor = self.highlightTextColor;
    } else if (self.hover) {
        textColor = self.hoverTextColor;
    } else if (NO == [self isEnabled]) {
        textColor = self.disabledTextColor;
    } else {
        textColor = self.textColor;
    }

    newTitle = [self p_setText:title textColor:textColor];

    return [super drawTitle:newTitle withFrame:frame inView:controlView];
}

- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [[self p_bezierPathForRect:cellFrame] fill];
}

- (NSRect)focusRingMaskBoundsForFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    return [[self p_bezierPathForRect:cellFrame] bounds];
}

#pragma mark - Private Methods

- (void)p_setupButtonCell
{
    self.borderColor = [NSColor alcatrazProgressGrayColor];
    [self setBackgroundColor:[NSColor whiteColor]];
    self.textColor = self.borderColor;

    self.disabledBorderColor = [self.borderColor colorWithAlphaComponent:0.5];
    self.disabledBackgroundColor = [self.backgroundColor colorWithAlphaComponent:0.5];
    self.disabledTextColor = self.disabledBorderColor;

    self.hoverBorderColor = [NSColor alcatrazBlueColor];
    self.hoverBackgroundColor = [NSColor whiteColor];
    self.hoverTextColor = self.hoverBorderColor;

    self.highlightBorderColor = [NSColor alcatrazBlueColor];
    self.highlightBackgroundColor = [NSColor alcatrazProgressBlueColor];
    self.highlightTextColor = [NSColor whiteColor];

    [self setButtonType:NSMomentaryChangeButton];
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

    NSBezierPath *roundedRect = [NSBezierPath bezierPathWithRoundedRect:insetRect
                                                                xRadius:BUTTON_CORNER_RADIUS
                                                                yRadius:BUTTON_CORNER_RADIUS];
    [roundedRect transformUsingAffineTransform:transform];

    return roundedRect;
}

- (NSAttributedString *)p_setText:(NSAttributedString *)string textColor:(NSColor *)textColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]];
    NSInteger len = [attributedString length];
    NSRange range = NSMakeRange(0, len);

    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:textColor
                             range:range];
    [attributedString fixAttributesInRange:range];
    return attributedString;
}

@end
