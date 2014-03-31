//
//  Created by Tony Arnold on 30/03/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, AZTInstallButtonCellState) {
    AZTInstallButtonCellStateNotInstalled = 0,
    AZTInstallButtonCellStateInstalling,
    AZTInstallButtonCellStateInstalled,
    AZTInstallButtonCellStateError,
    AZTInstallButtonCellStateCount
};

@interface ATZInstallButtonCell : NSButtonCell

@property(readwrite, nonatomic, assign) BOOL hover;

@property(readwrite, nonatomic, copy) NSColor *borderColor;
@property(readwrite, nonatomic, copy) NSColor *textColor;

@property(readwrite, nonatomic, copy) NSColor *disabledBorderColor;
@property(readwrite, nonatomic, copy) NSColor *disabledBackgroundColor;
@property(readwrite, nonatomic, copy) NSColor *disabledTextColor;

@property(readwrite, nonatomic, copy) NSColor *hoverBorderColor;
@property(readwrite, nonatomic, copy) NSColor *hoverBackgroundColor;
@property(readwrite, nonatomic, copy) NSColor *hoverTextColor;

@property(readwrite, nonatomic, copy) NSColor *highlightBorderColor;
@property(readwrite, nonatomic, copy) NSColor *highlightBackgroundColor;
@property(readwrite, nonatomic, copy) NSColor *highlightTextColor;

@property (nonatomic, assign) AZTInstallButtonCellState buttonCellState;
@property (nonatomic, assign) CGFloat progress;

@end
