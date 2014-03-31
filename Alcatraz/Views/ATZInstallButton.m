//
//  Created by Tony Arnold on 30/03/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import "ATZInstallButton.h"
#import "ATZInstallButtonCell.h"

@implementation ATZInstallButton

+ (Class)cellClass
{
    return [ATZInstallButtonCell class];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self createTrackingArea];
}

- (void)mouseEntered:(NSEvent *)event
{
    ATZInstallButtonCell *buttonCell = [self cell];

    buttonCell.hover = YES;

    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    ATZInstallButtonCell *buttonCell = [self cell];

    buttonCell.hover = NO;

    [self setNeedsDisplay:YES];
}

- (void)setButtonState:(AZTInstallButtonState)buttonState
{
    _buttonState = buttonState;

    ATZInstallButtonCell *buttonCell = [self cell];
    buttonCell.buttonCellState = (AZTInstallButtonCellState)buttonState;

    NSString *buttonTitle;
    // Update title appropriately
    switch (buttonState) {
        case AZTInstallButtonStateInstalled:
        {
            buttonTitle = NSLocalizedString(@"REMOVE", @"Plugin installation button title for installed state");
            break;
        }
        case AZTInstallButtonStateNotInstalled:
        {
            buttonTitle = NSLocalizedString(@"INSTALL", @"Plugin installation button title for not installed state");
            break;
        }
        case AZTInstallButtonStateInstalling:
        {
           buttonTitle = NSLocalizedString(@"INSTALL", @"Plugin installation button title for installing state");
            break;
        }
        case AZTInstallButtonStateError:
        {
            buttonTitle = NSLocalizedString(@"ERROR", @"Plugin installation button title for error state");
            break;
        }

        default:
            break;
    }

    [NSAnimationContext beginGrouping];
    [self setTitle:buttonTitle];
    [self setNeedsDisplay:YES];
    [NSAnimationContext endGrouping];
}

- (void)setButtonState:(AZTInstallButtonState)buttonState animated:(BOOL)animated
{
    if (animated) {
        self.animator.buttonState = buttonState;
    } else {
        self.buttonState = buttonState;
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;

    ATZInstallButtonCell *buttonCell = [self cell];
    buttonCell.progress = progress;

    [self setNeedsDisplay:YES];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        self.animator.progress = progress;
    } else {
        self.progress = progress;
    }
}

#pragma mark - Private

- (void)createTrackingArea
{
    NSTrackingAreaOptions focusTrackingAreaOptions = NSTrackingActiveInActiveApp | NSTrackingMouseEnteredAndExited | NSTrackingAssumeInside | NSTrackingInVisibleRect;

    NSTrackingArea *focusTrackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                     options:focusTrackingAreaOptions
                                                                       owner:self
                                                                    userInfo:nil];

    [self addTrackingArea:focusTrackingArea];
}

@end
