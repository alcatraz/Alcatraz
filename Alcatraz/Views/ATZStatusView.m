//
//  ATZStatusView.m
//  Alcatraz
//
//  Created by Delisa Mason on 4/23/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZStatusView.h"

@implementation ATZStatusView

- (void)drawRect:(NSRect)rect {
    NSRect frameRect = [self bounds];

    if(rect.size.height < frameRect.size.height) return;
    NSBezierPath *line = [NSBezierPath bezierPath];
    float y = CGRectGetMaxY(frameRect);
    [line moveToPoint:CGPointMake(CGRectGetMinX(frameRect), y)];
    [line lineToPoint:CGPointMake(CGRectGetMaxX(frameRect), y)];
    [line closePath];
    [line setLineWidth:1.f];
    [[NSColor colorWithDeviceWhite:0.25f alpha:1.f] set];
    [line stroke];
}

@end