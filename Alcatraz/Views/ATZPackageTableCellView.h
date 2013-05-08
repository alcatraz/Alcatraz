//
//  ATZPackageTableCellView.h
//  Alcatraz
//
//  Created by Jurre Stender on 5/8/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATZPackageTableCellView : NSTableCellView

@property (assign) IBOutlet NSView *buttonsContainerView;
@property (assign) IBOutlet NSButton *previewButton;
@property (assign) IBOutlet NSButton *websiteButton;

@end
