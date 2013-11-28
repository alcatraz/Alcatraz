//
//  ATZInstallCheckbox.m
//  Alcatraz
//
//  Created by Jurre Stender on 10/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "NSActionCell+Alcatraz.h"
#import "ATZPackageCheckboxCell.h"
#import "ATZPackage.h"
#import "Alcatraz.h"

@implementation ATZPackageCheckboxCell

- (void)drawImage:(NSImage *)image
        withFrame:(NSRect)frame
           inView:(NSView *)controlView {
    NSTableCellView *tableCell = (NSTableCellView *)[controlView superview];
    ATZPackage *package = [tableCell objectValue];

    NSImage *packageTypeImage = [[[Alcatraz sharedPlugin] bundle] imageForResource:package.iconName];

    [self drawIcon:packageTypeImage withSelection:package.isInstalled inFrame:frame];
}

@end
