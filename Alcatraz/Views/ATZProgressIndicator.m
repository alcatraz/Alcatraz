//
//  ATZProgressIndicator.m
//  Alcatraz
//
//  Created by Delisa Mason on 4/23/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZProgressIndicator.h"

@implementation ATZProgressIndicator

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void) drawRect:(NSRect)rect {
    [self setControlTint:NSGraphiteControlTint];
}
@end
