//
//  LLSegmentBarVC.m
//  LLSegmentBar
//
//  Created by liushaohua on 2017/6/3.
//  Copyright © 2017年 416997919@qq.com. All rights reserved.
//

#import "LLSegmentBarVC.h"

@interface LLSegmentBarVC ()<LLSegmentBarDelegate,UIScrollViewDelegate>


@end

@implementation LLSegmentBarVC

- (LLSegmentBar *)segmentBar{
    if (!_segmentBar) {
        LLSegmentBar *segmentBar = [LLSegmentBar segmentBarWithFrame:self.view.bounds];
        segmentBar.delegate = self;
        segmentBar.layer.shadowColor = [UIColor colorWithHexString:@"6570B5"].CGColor;
        segmentBar.layer.shadowOffset = CGSizeMake(0,0);
        segmentBar.layer.shadowRadius = 8;
        segmentBar.layer.shadowOpacity = 0.2;
        [self.view addSubview:segmentBar];
        _segmentBar = segmentBar;
    }
    return _segmentBar;
}

- (UIScrollView *)contentView {
    if (!_contentView) {
        
        UIScrollView *contentView = [[UIScrollView alloc] init];
        contentView.delegate = self;
        contentView.pagingEnabled = YES;
        [self.view addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.originY = 64;
}

- (void)setUpWithItems:(NSArray<NSString *> *)items childVCs:(NSArray<UIViewController *> *)childVCs{
    
    NSAssert(items.count != 0 || items.count == childVCs.count, @"个数不一致, 请自己检查");
    
    self.segmentBar.items = items;
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    for (UIViewController *vc in childVCs) {
        [self addChildViewController:vc];
    }
    
    self.contentView.contentSize = CGSizeMake(items.count * self.view.width, 0);
    
    self.segmentBar.selectIndex = 0;

}

- (void)showChildVCViewAtIndex:(NSInteger)index{
    
    if (self.childViewControllers.count == 0 || index < 0 || index > self.childViewControllers.count - 1) {
        return;
    }
    
    UIViewController *vc = self.childViewControllers[index];
    vc.view.frame = CGRectMake(index * self.contentView.width, 0, self.contentView.width, self.contentView.height);
    [self.contentView addSubview:vc.view];
    
    // 滑动到对应位置
    [self.contentView setContentOffset:CGPointMake(index * self.contentView.width, 0) animated:YES];
    
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
//    self.originY = self.view.sos_safeAreaInsets.top;
    CGRect contentFrame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.contentView.frame = contentFrame;
    if (self.segmentBar.superview == self.view) {
        
        self.segmentBar.frame = CGRectMake(0, self.originY , self.contentView.width, 44);
        
        CGFloat contentViewY = self.segmentBar.y + self.segmentBar.height;
        CGRect contentFrame = CGRectMake(0, contentViewY, self.view.width, self.view.height - contentViewY);
        self.contentView.frame = contentFrame;
        self.contentView.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);
        [self.view bringSubviewToFront:self.segmentBar];
        return;
    }
    self.contentView.contentSize = CGSizeMake(self.childViewControllers.count * self.view.width, 0);
    
    self.segmentBar.selectIndex = self.segmentBar.selectIndex;

}
#pragma mark - LLSegmentBarDelegate
- (void)segmentBar:(LLSegmentBar *)segmentBar didSelectIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex{
    [self showChildVCViewAtIndex:toIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentBar:didSelectIndex:fromIndex:)]) {
        [self.delegate segmentBar:segmentBar didSelectIndex:toIndex fromIndex:fromIndex];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger index = self.contentView.contentOffset.x/self.contentView.width;    
    self.segmentBar.selectIndex = index;
}

@end
