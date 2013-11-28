//
//  NSActionCell+Alcatraz.m
//  Alcatraz
//
//  Created by Jurre Stender on 25/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "NSActionCell+Alcatraz.h"

@implementation NSActionCell (Alcatraz)

- (void)drawIcon:(NSImage *)icon withSelection:(BOOL)selection inFrame:(NSRect)frame {
    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [graphicsContext graphicsPort];
    CGContextSaveGState(contextRef);

    // Flip the CG reference as it's upside-down
    CGContextTranslateCTM(contextRef, 0.0, frame.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);

    NSData *data = [icon TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (source) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);

        CGContextClipToMask(contextRef, NSRectToCGRect(frame), imageRef);
        if (selection) {
            [[NSColor colorWithDeviceRed:0.139 green:0.449 blue:0.867 alpha:1.000] setFill];
        } else {
            [[NSColor colorWithDeviceWhite:0.1f alpha:1.0f] setFill];
        }
        NSRectFill(frame);

        CFRelease(imageRef);
    }
    CGContextRestoreGState(contextRef);
}

@end
