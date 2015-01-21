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
    NSColor* clear = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0];
    NSColor* white = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* gray = [NSColor colorWithCalibratedRed: 0.378 green: 0.378 blue: 0.378 alpha: 1];
    NSColor* removeButtonColor = [NSColor colorWithCalibratedRed: 0.845 green: 0.236 blue: 0.362 alpha: 1];

    //// Variable Declarations
    CGFloat computedFillWidth = fillRatio * buttonWidth * 0.01;
    CGFloat fillWidth = computedFillWidth < 0 ? 0 : (computedFillWidth > buttonWidth ? buttonWidth : computedFillWidth);
    NSColor* buttonTextColor = fillRatio >= 40 ? white : ([buttonType isEqualToString: @"install"] ? buttonColor : gray);
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
    NSRect textRect = NSMakeRect(1, -2, buttonWidth, 20);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSCenterTextAlignment;

    NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont fontWithName: @"HelveticaNeue-Light" size: 12], NSForegroundColorAttributeName: buttonTextColor, NSParagraphStyleAttributeName: textStyle};

    [buttonText drawInRect: NSOffsetRect(textRect, 0, 4) withAttributes: textFontAttributes];
}

@end
