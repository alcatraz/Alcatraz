//
// ATZStyleKit.m
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

#import "ATZStyleKit.h"
#import "ATZPlugin.h"
#import "ATZFillableButton.h"

static NSString *const BUTTON_TITLE_INSTALL = @"INSTALL";
static NSString *const BUTTON_TITLE_REMOVE = @"REMOVE";
static NSString *const BUTTON_TITLE_BLOCKED = @"BLOCKED";

@implementation ATZStyleKit

#pragma mark ATZFillableButton styling

+ (void)updateButton:(ATZFillableButton *)fillableButton forPackageState:(ATZPackage *)package animated:(BOOL)animated {
    if ([package isInstalled]) {
        if ([package isBlacklisted]) {
            [fillableButton setTitle:BUTTON_TITLE_BLOCKED];
            [fillableButton setButtonStyle:ATZFillableButtonStyleBlocked];
            [fillableButton setFillRatio:0 animated:animated];
        }
        else {
            [fillableButton setTitle:BUTTON_TITLE_REMOVE];
            [fillableButton setButtonStyle:ATZFillableButtonStyleRemove];
            [fillableButton setFillRatio:1 animated:animated];
        }
    }
    else {
        [fillableButton setTitle:BUTTON_TITLE_INSTALL];
        [fillableButton setButtonStyle:ATZFillableButtonStyleInstall];
        [fillableButton setFillRatio:0 animated:animated];
    }
}

#pragma mark Drawing Methods

+ (void)drawFillableButtonWithText:(NSString*)text fillColor:(NSColor *)fillColor backgroundColor:(NSColor *)backgroundColor fillRatio:(float)fillRatio size:(CGSize)size {
    NSParameterAssert(0.0f <= fillRatio && fillRatio <= 1.0f);

    CGFloat cornerRadius = 2.0f;
    CGFloat borderWidth = 1.0f;
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    bounds = CGRectInset(bounds, borderWidth, borderWidth);
    bounds = CGRectIntegral(bounds);
    CGFloat fillWidth = bounds.size.width * fillRatio;

    //// Fill drawing
    CGRect fillRect = bounds;
    fillRect.size.width = fillWidth;
    NSBezierPath* fillPath = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:cornerRadius yRadius:cornerRadius];
    [fillColor setFill];
    [fillPath fill];

    //// Border drawing
    NSBezierPath* borderPath = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:cornerRadius yRadius:cornerRadius];
    [fillColor setStroke];
    [borderPath setLineWidth:borderWidth];
    [borderPath stroke];

    //// Text Drawing
    // Drawing the right part of the text with the fill color (eg. green)
    NSRect primaryColorClippingRect = bounds;
    primaryColorClippingRect.origin.x += fillWidth;
    primaryColorClippingRect.size.width -= fillWidth;
    [self drawText:text withColor:fillColor centeredInRect:bounds clippedToRect:primaryColorClippingRect];

    // Drawing the left part of the text with the background color (eg. white)
    NSRect secondaryColorClippingRect = bounds;
    secondaryColorClippingRect.size.width = fillWidth;
    [self drawText:text withColor:backgroundColor centeredInRect:bounds clippedToRect:secondaryColorClippingRect];
}

+ (void)drawText:(NSString*)text withColor:(NSColor *)color centeredInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect {
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;

    [NSGraphicsContext saveGraphicsState];

    CGPathRef clippingPath = CGPathCreateWithRect(clippingRect, NULL);
    CGContextAddPath(context, clippingPath);
    CGContextClip(context);

    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSCenterTextAlignment;
    textStyle.lineBreakMode = NSLineBreakByClipping;

    NSDictionary* textFontAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue-Light" size:12],
        NSForegroundColorAttributeName:color,
        NSParagraphStyleAttributeName:textStyle,
    };

    // Center the text vertically
    // A lot more complicated to get right than what I expected
    // See http://www.gameaid.org/2012/11/vertically-align-an-nsstring-in-an-nsrect/
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:text];
    [textStorage addAttributes:textFontAttributes range:NSMakeRange(0, text.length)];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:rect.size];
    textContainer.lineFragmentPadding = 0;

    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];

    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect textUsedRect = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint drawingPoint = CGPointMake(rect.origin.x, rect.origin.y + (rect.size.height - textUsedRect.size.height) / 2);

    // Finally draw the text
    [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:drawingPoint];

    [NSGraphicsContext restoreGraphicsState];
}

@end
