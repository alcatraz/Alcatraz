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
    NSColor* buttonColor = [NSColor colorWithCalibratedRed: 0.063 green: 0.856 blue: 0.483 alpha: 1];
    NSColor* clear = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0];
    NSColor* white = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* gray = [NSColor colorWithCalibratedRed: 0.378 green: 0.378 blue: 0.378 alpha: 1];
    NSColor* removeButtonColor = [NSColor colorWithCalibratedRed: 1 green: 0.162 blue: 0.162 alpha: 1];

    //// Variable Declarations
    CGFloat computedFillWidth = fillRatio * buttonWidth * 0.01;
    CGFloat fillWidth = computedFillWidth < 0 ? 0 : (computedFillWidth > buttonWidth ? buttonWidth : computedFillWidth);
    NSColor* buttonTextColor = fillRatio >= 40 ? white : ([buttonType isEqualToString: @"install"] ? buttonColor : gray);
    NSColor* buttonStrokeColor = [buttonType isEqualToString: @"install"] ? (fillRatio >= 100 ? removeButtonColor : buttonColor) : gray;
    NSColor* buttonFillColor = fillWidth <= 8 ? clear : (fillRatio >= 100 ? removeButtonColor : buttonStrokeColor);

    //// Rectangle Drawing
    NSBezierPath* rectanglePath = NSBezierPath.bezierPath;
    [rectanglePath moveToPoint: NSMakePoint(1, 5)];
    [rectanglePath curveToPoint: NSMakePoint(5.04, 1) controlPoint1: NSMakePoint(1, 2.79) controlPoint2: NSMakePoint(2.25, 1)];
    [rectanglePath lineToPoint: NSMakePoint(84.46, 1)];
    [rectanglePath curveToPoint: NSMakePoint(88.5, 5) controlPoint1: NSMakePoint(87.25, 1) controlPoint2: NSMakePoint(88.5, 2.79)];
    [rectanglePath lineToPoint: NSMakePoint(88.5, 21.5)];
    [rectanglePath curveToPoint: NSMakePoint(84.46, 25.5) controlPoint1: NSMakePoint(88.5, 23.71) controlPoint2: NSMakePoint(87.25, 25.5)];
    [rectanglePath lineToPoint: NSMakePoint(5.04, 25.5)];
    [rectanglePath curveToPoint: NSMakePoint(1, 21.5) controlPoint1: NSMakePoint(2.25, 25.5) controlPoint2: NSMakePoint(1, 23.71)];
    [rectanglePath lineToPoint: NSMakePoint(1, 5)];
    [rectanglePath closePath];
    [rectanglePath setLineCapStyle: NSRoundLineCapStyle];
    [rectanglePath setLineJoinStyle: NSRoundLineJoinStyle];
    [buttonStrokeColor setStroke];
    [rectanglePath setLineWidth: 1];
    [rectanglePath stroke];


    //// Rectangle 2 Drawing
    [NSGraphicsContext saveGraphicsState];
    CGContextTranslateCTM(context, 1, 2);

    NSBezierPath* rectangle2Path = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(0, -1.5, (fillWidth - 3), 25) xRadius: 4 yRadius: 4];
    [buttonFillColor setFill];
    [rectangle2Path fill];

    [NSGraphicsContext restoreGraphicsState];


    //// Text Drawing
    NSRect textRect = NSMakeRect(1, -2, (buttonWidth - 1), 20);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSCenterTextAlignment;

    NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont fontWithName: @"HelveticaNeue-Light" size: 12], NSForegroundColorAttributeName: buttonTextColor, NSParagraphStyleAttributeName: textStyle};

    [buttonText drawInRect: NSOffsetRect(textRect, 0, 4) withAttributes: textFontAttributes];
}

@end
