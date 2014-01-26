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

#import "ATZRadialProgressControl.h"
#import "NSImage+Alcatraz.h"
#import "NSColor+Alcatraz.h"
#import "ATZPackage.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat ATZRadialProgressControl_FakeInstallProgress = 0.33;
const CGFloat ATZRadialProgressControl_FakeRemoveProgress = 0.66;

@implementation ATZRadialProgressControl

#pragma mark - NSView

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = self.bounds;
    CGFloat minDimension = MIN(bounds.size.width, bounds.size.height);
    bounds.size = CGSizeMake(minDimension, minDimension);
    NSTableCellView *tableCell = (NSTableCellView *)self.superview;
    ATZPackage *package = [tableCell objectValue];
    if (self.progress == 0.f && package.isInstalled) _progress = 1.f;
    NSImage *image = [NSImage imageForProgressIndicatorWithCompletionPercentage:self.progress
                                                                        package:package
                                                                           size:bounds.size
                                                                          color:self.tintColor];
    [image drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
}

+ (id)defaultAnimationForKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(progress))]) {
        return [CABasicAnimation animation];
    }
    
    return [super defaultAnimationForKey:key];
}

#pragma mark - Progress

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    [self setNeedsDisplay:YES];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        self.animator.progress = progress;
    }
    else {
        self.progress = progress;
    }
}

#pragma mark - Private methods

- (NSColor *)tintColor
{
    return [[NSColor alcatrazProgressGrayColor] blendedColorWithFraction:self.progress
                                                                 ofColor:[NSColor alcatrazBlueColor]];
}

@end
