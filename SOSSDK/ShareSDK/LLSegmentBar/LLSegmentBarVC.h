//
//  LLSegmentBarVC.h
//  LLSegmentBar
//
//  Created by liushaohua on 2017/6/3.
//  Copyright © 2017年 416997919@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLSegmentBar.h"

/** Custom Delegate , 供 MainVC调用 */
@protocol LLSegmentBarVCDelegate <NSObject>

- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex;

@end

@interface LLSegmentBarVC : UIViewController

@property (nonatomic,weak) LLSegmentBar * segmentBar;
@property(nonatomic, assign) NSInteger originY;
@property (nonatomic,weak) UIScrollView * contentView;
@property (nonatomic, weak) id<LLSegmentBarVCDelegate> delegate;

- (void)setUpWithItems: (NSArray <NSString *>*)items childVCs: (NSArray <UIViewController *>*)childVCs;
- (void)showChildVCViewAtIndex:(NSInteger)index;

@end
