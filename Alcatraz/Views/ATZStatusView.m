//
//  ATZStatusView.m
//  Alcatraz
//
//  Created by Delisa Mason on 4/23/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZStatusView.h"

@implementation ATZStatusView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)drawRect:(NSRect)rect {
    [self drawBorder:rect];
}

-(void)drawBorder:(NSRect)rect {
    NSRect frameRect = [self bounds];

    if(rect.size.height < frameRect.size.height) return;
    NSBezierPath *textViewSurround = [NSBezierPath bezierPath];
    float y = CGRectGetMaxY(frameRect);
    [textViewSurround moveToPoint:CGPointMake(CGRectGetMinX(frameRect), y)];
    [textViewSurround lineToPoint:CGPointMake(CGRectGetMaxX(frameRect), y)];
    [textViewSurround closePath];
    [textViewSurround setLineWidth:1.f];
    [[NSColor colorWithDeviceWhite:0.25f alpha:1.f] set];
    [textViewSurround stroke];
}
@end