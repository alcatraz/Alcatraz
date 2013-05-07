//
//  ATZPackageTableView.h
//  Alcatraz
//
//  Created by Jurre Stender on 5/7/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATZPackageTableView : NSTableView {
    NSTrackingRectTag trackingTag;
    BOOL mouseOverView;
    int mouseOverRow;
    int lastOverRow;
}

- (int)mouseOverRow;

@end
