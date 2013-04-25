//
//  NSArray+Subscript.m
//  
//
//  Created by Sernin van de Krol on 8/21/12.
//  Copyright (c) 2012 Sernin van de Krol. All rights reserved.
//

#if __has_feature(objc_arc)

#import "NSArray+Subscript.h"

@implementation NSArray (Subscript)

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}

@end

#endif
