//
//  UITableView+SOSSafeReload.m
//  Onstar
//
//  Created by onstar on 2019/3/27.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "UITableView+SOSSafeReload.h"

@implementation UITableView (SOSSafeReload)

+ (void)load {
    [self swizzleInstanceMethod:@selector(reloadRow:inSection:withRowAnimation:) with:@selector(safeReloadRow:inSection:withRowAnimation:)];
}

- (void)safeReloadRow:(NSUInteger)row inSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
    if (cell) {
        [self safeReloadRow:row inSection:section withRowAnimation:animation];
    }else {
     
        [self reloadData];
    }
    
}

@end
