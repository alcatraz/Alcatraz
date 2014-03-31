//
//  Created by Tony Arnold on 30/03/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, AZTInstallButtonState) {
    AZTInstallButtonStateNotInstalled = 0,
    AZTInstallButtonStateInstalling,
    AZTInstallButtonStateInstalled,
    AZTInstallButtonStateError,
    AZTInstallButtonStateCount
};

@interface ATZInstallButton : NSButton

@property (nonatomic, assign) AZTInstallButtonState buttonState;
@property (nonatomic, assign) CGFloat progress;

- (void)setButtonState:(AZTInstallButtonState)buttonState animated:(BOOL)animated;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
