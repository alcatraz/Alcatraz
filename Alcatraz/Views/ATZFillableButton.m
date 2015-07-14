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

#import <Quartz/Quartz.h>
#import "ATZFillableButton.h"
#import "ATZStyleKit.h"

@interface ATZFillableButton ()

@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *fillColor;

@end

@implementation ATZFillableButton

+ (id)defaultAnimationForKey:(NSString *)key {
    if ([key isEqualToString:NSStringFromSelector(@selector(fillRatio))]) {
        return [CABasicAnimation animation];
    }

    return [super defaultAnimationForKey:key];
}

- (void)drawRect:(NSRect)dirtyRect {
    [ATZStyleKit drawFillableButtonWithText:self.title fillColor:self.fillColor backgroundColor:self.backgroundColor fillRatio:self.fillRatio size:self.bounds.size];
}

- (void)setButtonStyle:(ATZFillableButtonStyle)buttonStyle {
    _buttonStyle = buttonStyle;

    [self updateButtonColorsMatchingStyle:buttonStyle];
    [self setNeedsDisplay];
}

- (void)setFillRatio:(float)fillRatio {
    _fillRatio = fillRatio;
    [self setNeedsDisplay];
}

- (void)setFillRatio:(float)fillRatio animated:(BOOL)animated {
    if (animated) {
        self.animator.fillRatio = fillRatio;
    } else {
        self.fillRatio = fillRatio;
    }
}

- (void)updateButtonColorsMatchingStyle:(ATZFillableButtonStyle)buttonStyle {
    NSColor *installGreen = [NSColor colorWithCalibratedRed:0.311 green:0.699 blue:0.37 alpha:1];
    NSColor *removeRed = [NSColor colorWithCalibratedRed:0.845 green:0.236 blue:0.362 alpha:1];
    NSColor *blockedOrange = [NSColor colorWithCalibratedRed:0.869 green:0.413 blue:0.106 alpha:1];

    switch (buttonStyle) {
        case ATZFillableButtonStyleInstall:
            self.fillColor = installGreen;
            break;
        case ATZFillableButtonStyleRemove:
            self.fillColor = removeRed;
            break;
        case ATZFillableButtonStyleBlocked:
            self.fillColor = blockedOrange;
            break;
    }
    self.backgroundColor = [NSColor whiteColor];
}

@end
