//
//  ATZAnalytics.h
//  Alcatraz
//
//  Created by Marin Usalj on 3/11/15.
//  Copyright (c) 2015 supermar.in. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATZAnalytics : NSObject

/// Used for tracking internal Alcatraz events
void ATZLogEvent(NSString *name);
void ATZLogEventWithDictionary(NSString *name, NSDictionary *event);

@end
