//
//  ATZTableCellView.h
//  Alcatraz
//
//  Created by Marin Usalj on 3/2/14.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ATZRadialProgressControl;
@interface ATZTableCellView : NSTableCellView

@property (strong, nonatomic) IBOutlet ATZRadialProgressControl *progressControl;

@end
