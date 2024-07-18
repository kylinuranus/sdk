//
//  SOSScrollBaseTableHeaderView.h
//  Onstar
//
//  Created by lizhipan on 2017/7/24.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSPageScrollParaCenter.h"
@class SOSScrollBaseTableView;
typedef NS_ENUM(NSInteger, HomeHeaderState)
{
    HeaderStateFree  = 0,       ///-y <-> 60  ,自由滑动
    HeaderStateStick = 1,       ///60 <-> y   ,固定位置
    HeaderStateFollow = 2,      ///跟随tableview滑动
    HeaderStateDropDownFree  = 3,       ///-y <-> 60  ,自由滑动，下拉

};
@protocol HeaderSegmentChangeDelegate <NSObject>
- (void)segmentChange:(NSInteger)selectIndex;
@end

@protocol HitTestReceiverDelegate <NSObject>
- (SOSScrollBaseTableView*)hitTestReceiver;
@end

@interface SOSScrollBaseTableHeaderView : UIView
@property(nonatomic,assign)HomeHeaderState stickHeaderState;
@property (nonatomic,strong) UIView *headerBackgroundView; //主显示content的container
@property (nonatomic,strong) UISegmentedControl *titleSegment;//标题
@property (nonatomic,strong) UIView *lineView;                //下滑动线
@property (nonatomic ,weak) id <HeaderSegmentChangeDelegate>delegate;
@property (strong ,nonatomic)  NSArray * title;
@property (assign,nonatomic)  CGFloat lineViewWidth;  //记录底部线长度
@property (assign,nonatomic)  CGFloat titleTotalWidth;//标题segment总长度

- (instancetype)initWithFrame:(CGRect)frame scrollPara:(SOSPageScrollParaCenter *)para;
- (void)configTitleSegmentWidth:(CGFloat)width titleColor:(UIColor *)titleColor titleHighlightColor:(UIColor *)highlightColor highlightLineColor:(UIColor *)lineColor;
- (void)configHeader:(UIView *)headerV;
- (void)configBackground:(UIImage *)backbg;
@end
