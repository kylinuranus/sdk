//
//  UITableView+InfoFlow.m
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "UITableView+InfoFlow.h"

static NSString *shouldHideCellKey = @"shouldHideCellKey";


@implementation UITableView (InfoFlow)

- (void)setShouldHideCell:(BOOL)shouldHideCell {
    objc_setAssociatedObject(self, &shouldHideCellKey, @(shouldHideCell), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)shouldHideCell {
    return [objc_getAssociatedObject(self, &shouldHideCellKey) boolValue];
}



- (void)reloadDataAndshowCellAnimation {
    [self reloadDataAndshowCellAnimationWithCompletionBlock:nil];
}

- (void)reloadDataAndshowCellAnimationWithCompletionBlock:(void (^)(BOOL))finishBlock {
    self.shouldHideCell = YES;

    [self reloadData];
    
    NSTimeInterval totalTime = 0.5;
    
    for (int i = 0; i < self.visibleCells.count; i++) {
        UITableViewCell *cell = [self.visibleCells objectAtIndex:i];
        NSIndexPath *indexPath = [self indexPathForCell:cell];
        if (indexPath.section == 0) {
            continue;
        }
        cell.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT);
        cell.transform = CGAffineTransformScale(cell.transform, .5, .5);
        [UIView animateWithDuration:0.35 delay:i*(totalTime/self.visibleCells.count) options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.transform = CGAffineTransformIdentity;
            cell.contentView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finishBlock) {
                finishBlock(finished);
            }
        }];
    }
    self.shouldHideCell = NO;
}


- (__kindof NSObject *)configTrailingSwipeActionWithIndexPath:(NSIndexPath *)indexPath handler:(void (^)(NSIndexPath * _Nonnull))handler {
    if (@available(iOS 11.0, *)) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            handler ? handler(indexPath) : nil;
            completionHandler(YES);
        }];
        //iOS11以前的图标需要去SOSInfoFlowTableViewBaseCell中设置
        deleteAction.backgroundColor = [SOSUtil onstarLightGray];
        deleteAction.image = [UIImage imageNamed:@"icon_tile_del_60x60"];
        UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        return config;
    } else {
        // Fallback on earlier versions
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)  {
            handler ? handler(indexPath) : nil;
        }];
        return @[deleteAction];

    }

}

@end
