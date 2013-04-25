//
//  NSMutableDictionary+Subscript.h
//  
//
//  Created by Sernin van de Krol on 8/21/12.
//  Copyright (c) 2012 Sernin van de Krol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Subscript)

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;

@end
