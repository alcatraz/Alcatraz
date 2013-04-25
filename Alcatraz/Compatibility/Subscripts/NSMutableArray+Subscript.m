//
//  NSMutableArray+Subscript.m
//  
//
//  Created by Sernin van de Krol on 8/21/12.
//  Copyright (c) 2012 Sernin van de Krol. All rights reserved.
//
#if __has_feature(objc_arc)

#import "NSMutableArray+Subscript.h"

@implementation NSMutableArray (Subscript)

- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index
{
    if(anObject == nil)
    {
        [NSException raise:NSInvalidArgumentException format:@"setObject:atIndexedSubscript does not allow objects to be nil"];
    }
    if(index > self.count)
    {
        [NSException raise:NSRangeException format:@"setObject:atIndexedSubscript does not allow the index to be out of array bounds"];
    }
    if(index == self.count)
    {
        [self addObject:anObject];
    }
    else
    {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

@end

#endif
