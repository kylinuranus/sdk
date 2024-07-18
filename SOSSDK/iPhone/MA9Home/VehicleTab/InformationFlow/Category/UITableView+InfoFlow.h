//
//  UITableView+InfoFlow.h
//  Onstar
//
//  Created by TaoLiang on 2018/12/12.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (InfoFlow)


@property (assign, nonatomic) BOOL shouldHideCell;


//animation
- (void)reloadDataAndshowCellAnimation;
- (void)reloadDataAndshowCellAnimationWithCompletionBlock:(nullable void (^)(BOOL finished))finishBlock;

//trailing swipe actions
- (__kindof NSObject *)configTrailingSwipeActionWithIndexPath:(NSIndexPath *)indexPath handler:(void (^)(NSIndexPath *indexPath))handler;

@end

NS_ASSUME_NONNULL_END
