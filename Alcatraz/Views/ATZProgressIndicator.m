//
//  ATZProgressIndicator.m
//  Alcatraz
//
//  Created by Delisa Mason on 4/23/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZProgressIndicator.h"

@implementation ATZProgressIndicator

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setControlTint:NSGraphiteControlTint];
    return self;
}

@end