//
//  NSDictionary+Subscript.m
//  
//
//  Created by Sernin van de Krol on 8/21/12.
//  Copyright (c) 2012 Sernin van de Krol. All rights reserved.
//

#if __has_feature(objc_arc)

#import "NSDictionary+Subscript.h"

@implementation NSDictionary (Subscript)

-(id)objectForKeyedSubscript:(id)key
{
    return [self valueForKey:key];
}

@end

#endif
