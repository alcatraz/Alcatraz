//
//  ATZSegmentedCell.h
//  Alcatraz
//
//  Created by Jurre Stender on 25/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, ATZFilterSegment) {
    ATZFilterSegmentAll,
    ATZFilterSegmentPlugins,
    ATZFilterSegmentColorSchemes,
    ATZFilterSegmentTemplates
};

@interface ATZSegmentedCell : NSSegmentedCell

@end
