//
//  ATZTableCellView.m
//  Alcatraz
//
//  Created by Marin Usalj on 3/2/14.
//  Copyright (c) 2014 supermar.in. All rights reserved.
//

#import "ATZTableCellView.h"
#import "ATZRadialProgressControl.h"
#import "ATZPackage.h"

@implementation ATZTableCellView

- (void)setObjectValue:(id)objectValue {
    [super setObjectValue:objectValue];

    ATZPackage *package = objectValue;
    [self.progressControl setProgress:package.isInstalled ? 1 : 0];
}

@end
