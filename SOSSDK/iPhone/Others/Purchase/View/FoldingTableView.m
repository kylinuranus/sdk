//
//  FoldingTableView.m
//  Onstar
//
//  Created by Joshua on 6/9/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "FoldingTableView.h"

@implementation FoldingTableView

- (id)initWithFrame:(CGRect)frame     {
    self = [super initWithFrame:frame];
    if (self) {
        _expandedIndex = -1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder     {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _expandedIndex = -1;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect     {
    // Drawing code
}
*/

- (void)shrinkAndExpand:(NSInteger)section     {
    BOOL needExpand = (_expandedIndex != section);
    NSIndexPath *indexPathToChange = nil;
    if (_expandedIndex >= 0) {
        indexPathToChange = [NSIndexPath indexPathForRow:1 inSection:_expandedIndex];
        [self beginUpdates];
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToChange] withRowAnimation:UITableViewRowAnimationFade];
        _expandedIndex = -1;
        [self endUpdates];
    }
    
    if (needExpand) {
        indexPathToChange = [NSIndexPath indexPathForRow:1 inSection:section];
        [self beginUpdates];
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToChange] withRowAnimation:UITableViewRowAnimationFade];
        _expandedIndex = section;
        [self endUpdates];
    }
}

@end
