//
//  SOSSegmentView.m
//  Onstar
//
//  Created by lizhipan on 2017/7/18.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSSegmentView.h"
static CGFloat headerViewHeight = 50.0f;
@interface SOSSegmentView ()<UIScrollViewDelegate>{
    CGFloat _titleHeight;  //标题高度
//    CGFloat _lineViewWidth;  //记录底部线长度
}
@property (nonatomic,strong) UISegmentedControl *titleSegment;

@property (nonatomic,strong) UIScrollView *pageScrollView;

//@property (nonatomic,strong) UIView *lineView;

@end
@implementation SOSSegmentView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setting];
        
    }
    return self;
}
- (void)setting{
    self.backgroundColor = [SOSUtil onstarLightGray];
    //title
    _titleHeight = 40.f;
    self.titleSegment = [[UISegmentedControl alloc]initWithFrame:CGRectMake(-self.frame.size.width /2 + _titleHeight,(self.frame.size.height - headerViewHeight )/2, self.frame.size.width,_titleHeight)];
    self.titleSegment.tintColor = [UIColor clearColor];
    self.titleSegment.transform=CGAffineTransformMakeRotation(M_PI/2);

    NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],
                                             NSForegroundColorAttributeName: [UIColor colorWithHexString:@"107FE0"]};
    [self.titleSegment setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f],
                                               NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    [self.titleSegment setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
    [self.titleSegment addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    
    self.pageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.pageScrollView.bounces = NO;
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.scrollEnabled = NO;
    self.pageScrollView.showsVerticalScrollIndicator = NO;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    self.pageScrollView.delegate = self;
    [self addSubview:self.pageScrollView];
    
    [self addSubview:self.titleSegment];
    //底部线
//    self.lineView = [[UIView alloc]init];
//    self.lineView.backgroundColor = [UIColor blueColor];
//    [self addSubview:self.lineView];
}

#pragma mark --- title
- (void)setTitle:(NSArray *)title{
    if (title.count > 0) {
        for (NSInteger i = 0; i < title.count; i ++) {
            [self.titleSegment insertSegmentWithTitle:[title objectAtIndex:i] atIndex:i animated:NO];
        }
    }
    self.titleSegment.selectedSegmentIndex = 0;
}
#pragma mark --- 定制VC
- (void)setupViewControllerWithFatherVC:(UIViewController *)fatherVC childVC:(NSArray<UIViewController *>*)childVC{
//    NSInteger page = childVC.count;
    self.childrensVC = [NSArray arrayWithArray:childVC];
    self.fatherVC = fatherVC;
    
//    _lineViewWidth = self.frame.size.width / page;
//    self.lineView.frame = CGRectMake(0, _titleSegment.frame.origin.y+_titleSegment.frame.size.height,_lineViewWidth, 1.5);
//    self.pageScrollView.contentSize = CGSizeMake(self.frame.size.width * page, 0);
    
    for (NSInteger i = 0; i < 1; i ++) {
        UIViewController *vc = [childVC objectAtIndex:i];
        vc.view.frame = CGRectMake(self.frame.size.width * i, 0, self.frame.size.width, self.frame.size.height);
        [fatherVC addChildViewController:vc];
        self.selectVC = vc;
        [self.pageScrollView addSubview:vc.view];
    }
}
#pragma mark --- 联动设置
- (void)pageChange:(UISegmentedControl *)seg{
//    [self changeWithPage:seg.selectedSegmentIndex];
    UIViewController * vc = [self.childrensVC objectAtIndex:seg.selectedSegmentIndex];
    if (vc != self.selectVC) {
        [self.selectVC willMoveToParentViewController:nil];
        [self.selectVC removeFromParentViewController];
        [self.selectVC.view removeFromSuperview];
        self.selectVC = vc;
    }
    vc.view.frame = CGRectMake(0 , 0, self.frame.size.width, self.frame.size.height);
    [self.fatherVC addChildViewController:vc];
    [self.pageScrollView addSubview:vc.view];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([vc respondsToSelector:@selector(AVCaptureRunning)]) {
        [vc performSelector:@selector(AVCaptureRunning)];
    }
#pragma clang diagnostic pop

//    [self.pageScrollView setContentOffset:CGPointMake(self.frame.size.width *seg.selectedSegmentIndex,0) animated:NO];
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSInteger page = scrollView.contentOffset.x / self.frame.size.width;
//    self.titleSegment.selectedSegmentIndex = page;
//    [self changeWithPage:page];
//}

//- (void)changeWithPage:(NSInteger)page{
//    CGFloat lineViewCenterX = page *_lineViewWidth + _lineViewWidth / 2;
//    [UIView transitionWithView:self.lineView duration:0.3 options:      UIViewAnimationOptionAllowUserInteraction  animations:^{
//        self.lineView.center = CGPointMake(lineViewCenterX,_lineView.center.y);
//    } completion:^(BOOL finished) {
//    }];
//}

@end
