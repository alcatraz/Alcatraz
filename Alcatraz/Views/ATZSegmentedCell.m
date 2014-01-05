//
//  ATZSegmentedCell.m
//  Alcatraz
//
//  Created by Jurre Stender on 25/11/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZSegmentedCell.h"
#import "NSColor+Alcatraz.h"
#import "NSImage+Alcatraz.h"
#import "Alcatraz.h"
#import "ATZColorScheme.h"
#import "ATZPlugin.h"
#import "ATZTemplate.h"

static NSString *const ALL_ITEMS_TITLE = @"All";

@implementation ATZSegmentedCell

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    if (ATZFilterSegmentAll == segment) {
        [self drawAllItemsSegmentInFrame:frame];
    } else {
        NSImage *icon = [self iconForSegment:segment];
        CGFloat cellWidth = frame.size.width / self.segmentCount;
        CGRect segmentFrame = CGRectIntegral(CGRectMake(segment * cellWidth,
                                                        -((frame.size.height - icon.size.height) / 2), // we're drawing in a flipped context
                                                        icon.size.width,
                                                        icon.size.height));
        NSColor * color = [self colorForSegmentAtIndex:segment];
        [NSImage drawImage:icon withColor:color inFrame:segmentFrame flipVertically:YES];
    }
}

- (NSColor *)colorForSegmentAtIndex:(NSInteger)segmentIndex
{
    if (self.selectedSegment == segmentIndex) {
        return [NSColor alcatrazBlueColor];
    } else {
        return [NSColor colorWithDeviceWhite:0.1f alpha:1.0f];
    }
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    for (NSInteger segment = 0; segment < self.segmentCount; segment++) {
        [self drawSegment:segment inFrame:cellFrame withView:controlView];
    }
}

#pragma mark - Private

- (NSDictionary *)segmentIconMapping {
    static NSDictionary *segmentIconMapping;
    if (!segmentIconMapping) {
        segmentIconMapping = @{@(ATZFilterSegmentColorSchemes): COLOR_SCHEME_ICON_NAME,
                               @(ATZFilterSegmentPlugins): PLUGIN_ICON_NAME,
                               @(ATZFilterSegmentTemplates): TEMPLATE_ICON_NAME};
    }
    return segmentIconMapping;
}

- (NSImage *)iconForSegment:(ATZFilterSegment)segment {
    return [[[Alcatraz sharedPlugin] bundle] imageForResource:[self segmentIconMapping][@(segment)]];
}

- (void)drawAllItemsSegmentInFrame:(CGRect)frame {
    BOOL selected = self.selectedSegment == 0;
    NSAttributedString *title = selected ? [self allItemsLabelSelected] : [self allItemsLabelUnselected];
    frame.origin.y = (frame.size.height - title.size.height) / 2;
    [title drawInRect:frame];
}

- (NSMutableAttributedString *)allItemsLabelUnselected {
    static NSMutableAttributedString *allItemsLabelUnselected;
    if (!allItemsLabelUnselected) {
        allItemsLabelUnselected = [[NSMutableAttributedString alloc] initWithString:ALL_ITEMS_TITLE];
        NSRange fullRange = NSMakeRange(0, [allItemsLabelUnselected length]);
        [allItemsLabelUnselected addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13.0f] range:fullRange];
        [allItemsLabelUnselected addAttribute:NSForegroundColorAttributeName
                                        value:[NSColor blackColor]
                                        range:fullRange];
    }
    return allItemsLabelUnselected;
}

- (NSMutableAttributedString *)allItemsLabelSelected {
    static NSMutableAttributedString *allItemsLabelSelected;
    if (!allItemsLabelSelected) {
        allItemsLabelSelected = [[NSMutableAttributedString alloc] initWithString:ALL_ITEMS_TITLE];
        NSRange fullRange = NSMakeRange(0, [allItemsLabelSelected length]);
        [allItemsLabelSelected addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:13.0f] range:fullRange];
        [allItemsLabelSelected addAttribute:NSForegroundColorAttributeName
                                       value:[NSColor colorWithDeviceRed:0.139 green:0.449 blue:0.867 alpha:1.000]
                                       range:fullRange];
    }
    return allItemsLabelSelected;
}



@end
