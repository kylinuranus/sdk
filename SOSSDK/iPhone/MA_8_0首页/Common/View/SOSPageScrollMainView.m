//
//  SOSPageScrollMainView.m
//  Onstar
//
//  Created by lizhipan on 2017/7/20.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSPageScrollMainView.h"
#import "SOSScrollBaseTableView.h"
#import "SOSScrollBaseTableViewController.h"
@implementation SOSPageScrollMainView
- (instancetype)initWithFrame:(CGRect)frame tableViews:(NSArray *)tableviews tableTitle:(NSArray *)titles headerScrollParameter:(SOSPageScrollParaCenter *)scrollPara
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_pageScrollView) {
            _pageScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            _pageScrollView.contentSize = CGSizeMake(frame.size.width*tableviews.count, 0);
            _pageScrollView.showsVerticalScrollIndicator = YES;
            _pageScrollView.showsHorizontalScrollIndicator = YES;
            _pageScrollView.bounces = NO;
            _pageScrollView.pagingEnabled = YES;
            _pageScrollView.delegate = self;
            [self addSubview:_pageScrollView];
            [_pageScrollView mas_makeConstraints:^(MASConstraintMaker *make){
                make.edges.equalTo(self);
            }];
            
            _scrollPara = scrollPara;
            if (!_topHeaderView) {
                _topHeaderView = [[SOSScrollBaseTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width,scrollPara.headerTotalHeight) scrollPara:scrollPara];
                _topHeaderView.delegate = self;
                _topHeaderView.title = titles;
            }
            
            NSInteger index = 0;
            for (SOSScrollBaseTableViewController * everyTable in tableviews) {
                everyTable.view.x = index * frame.size.width;
                everyTable.table.topView = _topHeaderView;
                [_pageScrollView addSubview:everyTable.view];
                index = index + 1;
            }
            _tableViewControllerArray = tableviews;
            [self addSubview:_topHeaderView];
            _selectTableIndex = 0;
        }
    }
    return self;
}
- (void)configHeaderView:(UIView *)headerView withBackground:(UIImage *)bgimage
{
    [_topHeaderView configHeader:headerView];
    [_topHeaderView configBackground:bgimage];
}

#pragma mark ---scrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView    {
    [self calculateTableOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / self.frame.size.width;
    self.topHeaderView.titleSegment.selectedSegmentIndex = page;
    _selectTableIndex = page;
    [self changeWithPage:page];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollBlock) {
        self.scrollBlock(scrollView.contentOffset);
    }
}
#pragma mark --
- (void)segmentChange:(NSInteger)selectIndex
{
    if (_selectTableIndex != selectIndex) {
//        if (_tableViewControllerArray.count == 3) {
//            NSString *record = nil;
//            switch (selectIndex) {
//                case 0:
//                    record = SmartVehicle_Tab;
//                    break;
//                case 1:
//                    record = Startrip_Tab;
//                    break;
//                case 2:
//                    record = Joylife_Tab;
//                    break;
//                default:
//                    break;
//        }
//        [SOSDaapManager sendActionInfo:record];
//        }
        
        [self calculateTableOffset];
        _selectTableIndex = selectIndex;
        [self changeWithPage:selectIndex];
        [self.pageScrollView setContentOffset:CGPointMake(self.frame.size.width *selectIndex,0) animated:NO];
    }
    
}
- (void)adjustContentOffset
{
    SOSScrollBaseTableViewController * targetTabCon = [_tableViewControllerArray objectAtIndex:_selectTableIndex];
    if (targetTabCon.table.contentSize.height < targetTabCon.table.height) {
       [targetTabCon.table scrollToTop];
    }
}
- (void)calculateTableOffset    {
    CGFloat placeholderOffset = 0;
    placeholderOffset = _scrollPara.headerTotalHeight - _scrollPara.stickHeight;
    //数量很多时候可以只计算相邻将要显示的offset
    for (int i = 0; i < _tableViewControllerArray.count; i ++) {
        if (i != _selectTableIndex) {
            SOSScrollBaseTableViewController * willShowController = [_tableViewControllerArray objectAtIndex:i];
            switch (self.topHeaderView.stickHeaderState) {
                case HeaderStateFree:    {
                    SOSScrollBaseTableViewController * sourceTabCon = [_tableViewControllerArray objectAtIndex:_selectTableIndex];
                    [willShowController.table setContentOffset:sourceTabCon.table.contentOffset];
                    
                }
                    break;
                case HeaderStateStick:
                {
                     NSLog(@"/////HeaderStateStick,%f",willShowController.table.height);
                    if (willShowController.table.contentOffset.y < placeholderOffset) {
                        [willShowController.table setContentOffset:CGPointMake(0, placeholderOffset)];
                    }
                }
                    break;
                case HeaderStateFollow:
                {
                    NSLog(@"/////HeaderStateFollow");

                    SOSScrollBaseTableViewController * sourceTabCon = [_tableViewControllerArray objectAtIndex:_selectTableIndex];
                    if (sourceTabCon.table.contentOffset.y >willShowController.table.contentSize.height - willShowController.table.height) {
                        [willShowController.table setContentOffset:CGPointMake(0, willShowController.table.contentSize.height - willShowController.table.height)];
                    }
                    else
                    {
                        [willShowController.table setContentOffset:sourceTabCon.table.contentOffset];
                    }
                }
                    break;
                case HeaderStateDropDownFree:
                {
                    SOSScrollBaseTableViewController * sourceTabCon = [_tableViewControllerArray objectAtIndex:_selectTableIndex];
                    [sourceTabCon.table setContentOffset:CGPointMake(0, 0)];
                    [willShowController.table setContentOffset:CGPointMake(0, 0)];
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
}
- (void)changeWithPage:(NSInteger)page{
    
    CGFloat lineViewCenterX = page *self.topHeaderView.lineViewWidth + self.topHeaderView.lineViewWidth / 2 + (self.topHeaderView.width - self.topHeaderView.titleSegment.width ) /2;
    [UIView transitionWithView:self.topHeaderView.lineView duration:0.1 options:      UIViewAnimationOptionAllowUserInteraction  animations:^{
        self.topHeaderView.lineView.center = CGPointMake(lineViewCenterX,self.topHeaderView.lineView.center.y);
    } completion:^(BOOL finished) {
        [self adjustContentOffset];
    }];
}

@end
