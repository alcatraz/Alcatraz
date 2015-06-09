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


@implementation ATZStyleKit

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawFillableButtonWithButtonText: (NSString*)buttonText fillRatio: (CGFloat)fillRatio buttonWidth: (CGFloat)buttonWidth buttonType: (NSString*)buttonType
{
    //// General Declarations
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;

    //// Color Declarations
    NSColor* buttonColor = [NSColor colorWithCalibratedRed: 0.311 green: 0.699 blue: 0.37 alpha: 1];
    NSColor* clear = [NSColor clearColor];
    NSColor* white = [NSColor whiteColor];
    NSColor* gray = [NSColor colorWithCalibratedRed: 0.378 green: 0.378 blue: 0.378 alpha: 1];
    NSColor* removeButtonColor = [NSColor colorWithCalibratedRed: 0.845 green: 0.236 blue: 0.362 alpha: 1];

    //// Variable Declarations
    CGFloat computedFillWidth = fillRatio * buttonWidth * 0.01;
    CGFloat fillWidth = computedFillWidth < 0 ? 0 : (computedFillWidth > buttonWidth ? buttonWidth : computedFillWidth);
    NSColor* buttonTextPrimaryColor = [buttonType isEqualToString: @"install"] ? buttonColor : gray;
    NSColor* buttonTextSecondaryColor = white;
    NSColor* buttonStrokeColor = [buttonType isEqualToString: @"install"] ? (fillRatio >= 100 ? removeButtonColor : buttonColor) : gray;
    NSColor* buttonFillColor = fillWidth <= 8 ? clear : (fillRatio >= 100 ? removeButtonColor : buttonStrokeColor);

    //// borderRect Drawing
    NSBezierPath* borderRectPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(1, 1, (buttonWidth - 3), 25) xRadius: 2 yRadius: 2];
    [buttonStrokeColor setStroke];
    [borderRectPath setLineWidth: 1];
    [borderRectPath stroke];


    //// fillRect Drawing
    [NSGraphicsContext saveGraphicsState];
    CGContextTranslateCTM(context, 1, 2);

    NSBezierPath* fillRectPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(0, -1.5, (fillWidth - 3), 25) xRadius: 2 yRadius: 2];
    [buttonFillColor setFill];
    [fillRectPath fill];

    [NSGraphicsContext restoreGraphicsState];


    //// Text Drawing
    CGFloat textInset = 4;
    NSRect textRect = NSMakeRect(1, -2, buttonWidth, 20);
    textRect = NSOffsetRect(textRect, 0, 4);

    // Drawing the right part of the text with the primary color (eg. green)
    NSRect primaryColorClippingRect = textRect;
    primaryColorClippingRect.origin.x += fillWidth - textInset;
    primaryColorClippingRect.size.width -= fillWidth - textInset;
    [self drawText:buttonText withColor:buttonTextPrimaryColor centeredInRect:textRect clippedToRect:primaryColorClippingRect];

    // Drawing the left part of the text with the secondary color (eg. white)
    NSRect secondaryColorClippingRect = textRect;
    secondaryColorClippingRect.size.width = fillWidth - textInset;
    [self drawText:buttonText withColor:buttonTextSecondaryColor centeredInRect:textRect clippedToRect:secondaryColorClippingRect];
}

+ (void)drawText:(NSString*)text withColor:(NSColor *)color centeredInRect:(NSRect)rect clippedToRect:(NSRect)clippingRect
{
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;

    [NSGraphicsContext saveGraphicsState];

    CGPathRef clippingPath = CGPathCreateWithRect(clippingRect, NULL);
    CGContextAddPath(context, clippingPath);
    CGContextClip(context);

    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSCenterTextAlignment;

    NSDictionary* textFontAttributes = @{
        NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue-Light" size:12],
        NSForegroundColorAttributeName:color,
        NSParagraphStyleAttributeName: textStyle
    };

    [text drawInRect:rect withAttributes:textFontAttributes];

    [NSGraphicsContext restoreGraphicsState];
}

@end
