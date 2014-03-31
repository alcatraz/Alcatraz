//
//  Created by Tony Arnold on 27/01/2014.
//  Copyright (c) 2014 The CocoaBots. All rights reserved.
//

#import "ATZHeightAutosizingTextField.h"

// Categories
#import "NSAttributedString+Geometry.h"

@implementation ATZHeightAutosizingTextField

- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
    [self invalidateIntrinsicContentSize];
}

- (void)resizeSubviewsWithOldSize:(CGSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
    self.preferredMaxLayoutWidth = NSWidth([self bounds]);
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    self.preferredMaxLayoutWidth = NSWidth([self bounds]);
}

- (void)setObjectValue:(id<NSCopying>)obj
{
    [super setObjectValue:obj];
    [self invalidateIntrinsicContentSize];
}

- (NSSize)intrinsicContentSize
{
    NSAttributedString *attributedString = [self attributedStringValue];
    NSSize intrinsicContentSize = [attributedString sizeForWidth:self.preferredMaxLayoutWidth height:CGFLOAT_MAX];

    return intrinsicContentSize;
}

@end
