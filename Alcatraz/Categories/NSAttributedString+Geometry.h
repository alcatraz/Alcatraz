//
//  Created by Tony Arnold on 15/03/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSInteger gNSStringGeometricsTypesetterBehavior;

@interface NSAttributedString (Geometry)

- (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height;
- (CGFloat)heightForWidth:(CGFloat)width;
- (CGFloat)widthForHeight:(CGFloat)height;

@end

@interface NSString (Geometry)

// Measuring a String With Attributes
- (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height attributes:(NSDictionary *)attributes;
- (CGFloat)heightForWidth:(CGFloat)width attributes:(NSDictionary *)attributes;
- (CGFloat)widthForHeight:(CGFloat)height attributes:(NSDictionary *)attributes;

// Measuring a String with a constant Font
- (NSSize)sizeForWidth:(CGFloat)width height:(CGFloat)height font:(NSFont *)font;
- (CGFloat)heightForWidth:(CGFloat)width font:(NSFont *)font;
- (CGFloat)widthForHeight:(CGFloat)height font:(NSFont *)font;

@end
