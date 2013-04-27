// PluginWindowController.m
//
// Copyright (c) 2013 Marin Usalj | mneorr.com
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

#import "ATZShadowScrollView.h"


@interface ATZShadowScrollView () {}
@property (nonatomic, retain) ATZShadowView *topShadowView;
@property (nonatomic, retain) ATZShadowView *bottomFadeView;
@end

@implementation ATZShadowScrollView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _hasShadows = YES;
    }
    return self;
}

- (void)tile
{
    [super tile];

    NSRect bounds = [self bounds];
    if (!self.topShadowView) {
        self.topShadowView = [[ATZShadowView alloc] init];
        [self addSubview:self.topShadowView positioned:NSWindowAbove relativeTo:[self contentView]];
    }
    if (!self.bottomFadeView) {
        self.bottomFadeView = [[ATZShadowView alloc] init];
        self.bottomFadeView.edge = ATZShadowViewEdgeBottom;
        self.bottomFadeView.gradientColor = [NSColor colorWithCalibratedWhite:0.278 alpha:1.000];
        [self addSubview:self.bottomFadeView positioned:NSWindowAbove relativeTo:[self contentView]];
    }
    self.topShadowView.frame = NSMakeRect(0, 0, NSWidth(bounds), 6);
    self.bottomFadeView.frame = NSMakeRect(0, NSMaxY(bounds)-12, NSWidth(bounds), 12);

	[self.topShadowView setNeedsDisplay:YES];
	[self.bottomFadeView setNeedsDisplay:YES];
}

- (void)dealloc
{
    [_topShadowView release];
    _topShadowView = nil;
    [_bottomFadeView release];
    _bottomFadeView = nil;

    [super dealloc];
}
@end



@interface ATZShadowView () {
    NSArray *_gradientColors;
    NSGradient *_gradient;
}
@property (nonatomic, readonly, retain) NSArray *gradientColors;
@property (nonatomic, readonly, retain) NSGradient *gradient;
@end
@implementation ATZShadowView

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _edge = ATZShadowViewEdgeTop;
    _gradientColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
}

- (void)dealloc
{
    [_gradientColors release];
    _gradientColors = nil;
    [_gradient release];
    _gradient = nil;
    [_gradientColor release];
    _gradientColor = nil;

    [super dealloc];
}

- (NSArray *)gradientColors
{
    _gradientColors = [[[NSArray alloc] initWithObjects:
                        [[self gradientColor] colorWithAlphaComponent:0.30],
                        [[self gradientColor] colorWithAlphaComponent:0.13],
                        [[self gradientColor] colorWithAlphaComponent:0.0], nil] autorelease];
    return _gradientColors;
}

- (NSGradient *)gradient
{
    _gradient = [[[NSGradient alloc] initWithColors:[self gradientColors]] autorelease];
    return _gradient;
}

- (void)drawRect:(NSRect)rect {
    [[self gradient] drawInRect:rect angle:(self.edge == ATZShadowViewEdgeTop ? -90 : 90)];
    if (self.edge == ATZShadowViewEdgeBottom) {
        NSRect bounds = [self bounds];
        [[NSColor darkGrayColor] setStroke];
        NSBezierPath *bottomLinePath = [NSBezierPath bezierPath];
        [bottomLinePath moveToPoint:NSMakePoint(0, NSMinY(bounds))];
        [bottomLinePath lineToPoint:NSMakePoint(NSWidth(bounds), NSMinY(bounds))];
        [bottomLinePath closePath];
        [bottomLinePath stroke];
    }
}

@end
