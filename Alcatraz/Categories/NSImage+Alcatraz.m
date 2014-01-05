// NSImage+Alcatraz.m
//
// Copyright (c) 2013 Dave Schukin
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

#import "Alcatraz.h"
#import "NSImage+Alcatraz.h"
#import "ATZPackage.h"

static CGFloat const STROKE_WIDTH = 1.f;

@implementation NSImage (Alcatraz)

+ (NSImage *)imageForProgressIndicatorWithCompletionPercentage:(CGFloat)progress package:(ATZPackage *)package size:(CGSize)size color:(NSColor *)color {
    NSImage *image          = [[NSImage alloc] initWithSize:size];
    NSRect ovalRect         = NSMakeRect(0, 0, size.width, size.height);

    [image lockFocus];
    if (fmod(progress, 1.f) == 0) {
        NSImage *icon = [[[Alcatraz sharedPlugin] bundle] imageForResource:package.iconName];
        [self drawImage:icon withColor:color inFrame:ovalRect flipVertically:NO];
    } else {
        [self drawPieInRect:ovalRect usingColor:color withProgressPercentage:progress];
        [self strokeInRect:ovalRect usingColor:color];
    }
    [image unlockFocus];
    return image;
}

+ (void)drawImage:(NSImage *)icon withColor:(NSColor *)color inFrame:(NSRect)frame flipVertically:(BOOL)shouldFlip {
    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [graphicsContext graphicsPort];
    CGContextSaveGState(contextRef);

    if (shouldFlip) {
        CGContextTranslateCTM(contextRef, 0.0, frame.size.height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
    }

    NSData *data = [icon TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (source) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);

        CGContextClipToMask(contextRef, NSRectToCGRect(frame), imageRef);
        [color setFill];
        NSRectFill(frame);

        CFRelease(imageRef);
    }
    CGContextRestoreGState(contextRef);
}

+ (void)drawPieInRect:(NSRect)ovalRect usingColor:(NSColor *)color withProgressPercentage:(CGFloat)progress {
    CGFloat ovalStartAngle  = 90;
    CGFloat ovalEndAngle    = 90 - (360 * progress);
    NSBezierPath *ovalPath = [NSBezierPath bezierPath];
    [ovalPath appendBezierPathWithArcWithCenter:NSMakePoint(NSMidX(ovalRect), NSMidY(ovalRect))
                                         radius:NSWidth(ovalRect) / 2
                                     startAngle:ovalStartAngle
                                       endAngle:ovalEndAngle
                                      clockwise:YES];
    [ovalPath lineToPoint:NSMakePoint(NSMidX(ovalRect), NSMidY(ovalRect))];
    [ovalPath closePath];

    [color setFill];
    [ovalPath fill];
}

+ (void)strokeInRect:(NSRect)rect usingColor:(NSColor *)color {
    NSRect strokeRect = NSInsetRect(rect, STROKE_WIDTH / 2.0, STROKE_WIDTH / 2.0);
    NSBezierPath *ovalPath = [NSBezierPath bezierPathWithOvalInRect:strokeRect];
    [color setStroke];
    [ovalPath setLineWidth:STROKE_WIDTH];
    [ovalPath stroke];
}

@end
