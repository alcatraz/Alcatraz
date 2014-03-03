//
// ATZVersionLabel.m
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

#import "ATZVersionLabel.h"

// Don't update these numbers manually. They're automatically updated from a rake task
#define ATZ_VERSION "1.0.1"
#define ATZ_REVISION "d7115ea"

@implementation ATZVersionLabel

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) [self setStyle];
    return self;
}

- (void)setStyle {
    self.backgroundColor   = [NSColor clearColor];
    self.layer.borderColor = [NSColor clearColor].CGColor;
    self.textColor         = [NSColor colorWithDeviceWhite:0.75 alpha:1.f];
    self.layer.shadowColor = [NSColor blackColor].CGColor;
    self.layer.borderWidth = 0.f;
    self.stringValue       = [NSString stringWithFormat:@"v%s", ATZ_VERSION];
    self.alignment         = NSRightTextAlignment;
    self.layer.shadowOpacity = 0.3f;

    [self setFont:[NSFont fontWithName:@"Lucida Grande" size:11.f]];
    [self setBezeled:NO];
    [self setDrawsBackground:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
    [self setToolTip:[NSString stringWithFormat:@"revision: %s", ATZ_REVISION]];
}

@end
