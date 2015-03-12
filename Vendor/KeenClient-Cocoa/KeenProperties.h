//
//  KeenProperties.h
//  KeenClient
//
//  Created by Daniel Kador on 12/7/12.
//  Copyright (c) 2012 Keen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 This class is used to represent Keen-specific properties that can be included on each event.
 Today this includes timestamp and location.
 */
@interface KeenProperties : NSObject

/**
 The time a particular event occured. The Keen Client will automatically generate this for you,
 but you can set it yourself if you'd like.
 */
@property (nonatomic, strong) NSDate *timestamp;

/**
 The location where a particular event occured. The Keen Client will automatically generate this for you,
 but you can set it yourself if you'd like.
 */
@property (nonatomic, strong) CLLocation *location;

@end
