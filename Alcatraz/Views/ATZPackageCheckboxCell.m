//
//  ATZInstallCheckbox.m
//  Alcatraz
//
//  Created by Jurre Stender on 10/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZPackageCheckboxCell.h"
#import "ATZPackage.h"
#import "Alcatraz.h"

@implementation ATZPackageCheckboxCell

- (void)drawIconForPackage:(NSImage *)packageTypeImage package:(ATZPackage *)package inFrame:(NSRect)frame
{
    NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];
    CGContextRef contextRef = [graphicsContext graphicsPort];

    // Flip the CG reference as it's upside-down
    CGContextTranslateCTM(contextRef, 0.0, frame.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);

    NSData *data = [packageTypeImage TIFFRepresentation];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if(source) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);
        
        CGContextSaveGState(contextRef);
        {
            CGContextClipToMask(contextRef, NSRectToCGRect(frame), imageRef);
            if (package.isInstalled) {
                [[NSColor colorWithDeviceRed:0.139 green:0.449 blue:0.867 alpha:1.000] setFill];
            } else {
                [[NSColor colorWithDeviceWhite:0.1f alpha:1.0f] setFill];
            }
            NSRectFill(frame);
        } 
        CGContextRestoreGState(contextRef);        
        
        CFRelease(imageRef);
    }
}

- (void)drawImage:(NSImage *)image
        withFrame:(NSRect)frame
           inView:(NSView *)controlView {
    NSTableCellView *tableCell = (NSTableCellView *)[controlView superview];
    ATZPackage *package = [tableCell objectValue];

    NSImage *packageTypeImage = [[[Alcatraz sharedPlugin] bundle] imageForResource:package.iconName];

    [self drawIconForPackage:packageTypeImage package:package inFrame:frame];
}

@end
