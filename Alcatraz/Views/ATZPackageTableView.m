//
//  ATZPackageTableView.m
//  Alcatraz
//
//  Created by Jurre Stender on 5/7/13.
//  Copyright (c) 2013 mneorr.com. All rights reserved.
//

#import "ATZPackageTableView.h"

@implementation ATZPackageTableView

- (void)awakeFromNib {
    [[self window] setAcceptsMouseMovedEvents:YES];
    trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
    mouseOverView = NO;
    mouseOverRow = -1;
    lastOverRow = -1;
}

- (void)dealloc {
    [self removeTrackingRect:trackingTag];
    [super dealloc];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self removeTrackingRect:trackingTag];
    trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
    mouseOverView = YES;
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [self highlightCellForEvent:theEvent];
}


- (void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    [self highlightCellForEvent:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    int rowToDisplay = mouseOverRow;
    mouseOverView = NO;
    mouseOverRow = -1;
    lastOverRow = -1;
    if (rowToDisplay >= 0) {
        [self.delegate tableView:self willDisplayCell:self.cell forTableColumn:self.tableColumns[1] row:rowToDisplay];
    }
}

- (int)mouseOverRow {
    return mouseOverRow;
}

- (void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    [self removeTrackingRect:trackingTag];
    trackingTag = [self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
}

#pragma mark - Private

- (void)highlightCellForEvent:(NSEvent *)theEvent {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(tableView:willDisplayCell:forTableColumn:row:)]) {
        return; // No delegate set or it doesn't customize the drawing of its cells
    }
    
    if (mouseOverView) {
        mouseOverRow = (int)[self rowAtPoint:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
    }
    
    if (lastOverRow == mouseOverRow) {
        return; // already highlighting this cell
    } else {
        // remove highlighting from previous cell
        if (lastOverRow >= 0) {
            [self.delegate tableView:self willDisplayCell:self.cell forTableColumn:self.tableColumns[1] row:lastOverRow];
        }
        lastOverRow = mouseOverRow;
    }
    
    [self.delegate tableView:self willDisplayCell:self.cell forTableColumn:self.tableColumns[1] row:mouseOverRow];
}

@end

