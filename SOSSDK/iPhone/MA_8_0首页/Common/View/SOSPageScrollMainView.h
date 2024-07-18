//
//  SOSPageScrollMainView.h
//  Onstar
//
//  Created by lizhipan on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSScrollBaseTableHeaderView.h"
#import "SOSPageScrollParaCenter.h"
typedef void (^SOSPageScrollBlock)(CGPoint scrollContentoffset);

@interface SOSPageScrollMainView : UIView<UIScrollViewDelegate,HeaderSegmentChangeDelegate>
@property (assign ,nonatomic)CGFloat headerTotalHeight;
@property (strong ,nonatomic)SOSPageScrollParaCenter *scrollPara;
@property (strong ,nonatomic) SOSScrollBaseTableHeaderView *topHeaderView;
@property (assign ,nonatomic) NSInteger    selectTableIndex;
@property (strong, nonatomic) NSArray * tableViewControllerArray; //存放tableview所在的controller
@property (copy ,nonatomic)   SOSPageScrollBlock scrollBlock;
@property (assign,nonatomic)  BOOL enableHeader;
@property (strong,nonatomic)  UIScrollView *pageScrollView;
- (instancetype)initWithFrame:(CGRect)frame tableViews:(NSArray *)tableviews tableTitle:(NSArray *)titles headerScrollParameter:(SOSPageScrollParaCenter *)scrollPara;
- (void)configHeaderView:(UIView *)headerView withBackground:(UIImage *)bgimage;



@end
