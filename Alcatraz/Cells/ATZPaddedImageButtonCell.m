//
//  Created by Tony Arnold on 31/03/2014.
//  Copyright (c) 2014 mneorr.com. All rights reserved.
//
//  Implementation taken from http://notwaldorf.github.io/posts/cocoa-gems/
//

#import "ATZPaddedImageButtonCell.h"

@implementation ATZPaddedImageButtonCell

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    // This is the text's origin, which is from the left margin of the button.
    // If you add a left margin in -drawImage, you have to add it here as well.
    frame.origin.x += self.spacingBetweenImageAndText;
    return [super drawTitle:title withFrame:frame inView:controlView];
}

- (NSSize)cellSize
{
    NSSize buttonSize = [super cellSize];

    buttonSize.width += self.spacingBetweenImageAndText;
    return buttonSize;
}

@end
