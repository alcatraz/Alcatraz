//
//  NSActionCell+Alcatraz.h
//  Alcatraz
//
//  Created by Jurre Stender on 25/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSActionCell (Alcatraz)

- (void)drawIcon:(NSImage *)icon withSelection:(BOOL)selection inFrame:(NSRect)frame;

@end
