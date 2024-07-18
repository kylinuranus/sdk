//
//  OwnerLifeBannerView.m
//  Onstar
//
//  Created by Apple on 17/1/10.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "OwnerLifeBannerView.h"
#import "RequestDataObject.h"
#import "UIImageView+WebCache.h"
#import "SOSWebViewController.h"
#import "SOSSearchResult.h"
#import "CustomerInfo.h"
#import "DispatchUtil.h"
@interface OwnerLifeBannerView()<UIScrollViewDelegate>
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSTimer *timer;
@end

@implementation OwnerLifeBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.userInteractionEnabled = YES;
        [self addSubview:self.scrollView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height-10, self.width, 0)];
        [self addSubview:self.pageControl];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#ed0707"];
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.alpha = 0.4;
    }
    return self;
}

- (void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    
    if (IsArrEmpty(_imageArray)) return;
    
    for (UIView *subView in self.scrollView.subviews) {
        [subView removeFromSuperview];
    }
    
    CGFloat scrollW = self.scrollView.width;
    CGFloat scrollH = self.scrollView.height;
    
    if (_imageArray.count>1)
    {
        //在最前面加上最后一张图片
        UIImageView *imgv= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, scrollW, scrollH)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadAdPage:)];
        imgv.userInteractionEnabled = YES;
        imgv.tag = _imageArray.count-1;
        [imgv addGestureRecognizer:tap];
        
        NNMyPreferentialModel *adModel = _imageArray[_imageArray.count-1];
        [imgv sd_setImageWithURL:[NSURL URLWithString:adModel.imgUrl] placeholderImage:[UIImage imageNamed:@"homePage_my_preferential_hot_activity_default"]];
        [self.scrollView addSubview:imgv];
    }
    
    for (int i = 0; i<_imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadAdPage:)];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        [imageView addGestureRecognizer:tap];
        
        imageView.width = scrollW;
        imageView.height = scrollH;
        imageView.y = 0;
        if (_imageArray.count>1)
        {
            imageView.x = (i+1) * scrollW;
        }
        else
        {
            imageView.x = i * scrollW;
        }
        // 显示图片
        NNMyPreferentialModel *adModel = _imageArray[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:adModel.imgUrl] placeholderImage:[UIImage imageNamed:@"homePage_my_preferential_hot_activity_default"]];
        [self.scrollView addSubview:imageView];
    }
    
    if (_imageArray.count>1)
    {
        //在最后面加上第一张图片
        UIImageView *imgv2= [[UIImageView alloc] initWithFrame:CGRectMake((_imageArray.count+1)*scrollW, 0, scrollW, scrollH)];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadAdPage:)];
        imgv2.userInteractionEnabled = YES;
        imgv2.tag = 0;
        [imgv2 addGestureRecognizer:tap];
        
        NNMyPreferentialModel *adModel = _imageArray[0];
        [imgv2 sd_setImageWithURL:[NSURL URLWithString:adModel.imgUrl] placeholderImage:[UIImage imageNamed:@"homePage_my_preferential_hot_activity_default"]];
        [self.scrollView addSubview:imgv2];
    }
    
    // 3.设置scrollView的其他属性
    // 如果想要某个方向上不能滚动，那么这个方向对应的尺寸数值传0即可
    if (_imageArray.count>1)
    {
        self.scrollView.contentSize = CGSizeMake((_imageArray.count+2) * scrollW, 0);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(_imageArray.count * scrollW, 0);
    }
    self.scrollView.bounces = NO; // 去除弹簧效果
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    //先滚动到第一张图片的位置
    if (_imageArray.count>1)
    {
        self.scrollView.contentOffset = CGPointMake(scrollW, 0);
    }
    
    if (_imageArray.count>1)
    {
        _pageControl.hidden = NO;
        _pageControl.numberOfPages = _imageArray.count;
        _pageControl.enabled = NO;
        _pageControl.currentPage = 0;
    }
    else
    {
        _pageControl.hidden = YES;
    }
    
    if (_timer == nil)
    {
        [self startTimer];
    }
}


- (void)startTimer
{
    _timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimer
{
    self.pageControl.currentPage =  (self.pageControl.currentPage+1)%_imageArray.count;
    if (_imageArray.count == 1) {
        return;
    }
    if (self.pageControl.currentPage == 0)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.scrollView.contentOffset = CGPointMake((_imageArray.count+1)*self.scrollView.bounds.size.width, 0);
        } completion:^(BOOL finished) {
            self.scrollView.contentOffset = CGPointMake(1*self.scrollView.bounds.size.width, 0);
        }];
    }
    else
    {
        [self.scrollView setContentOffset:CGPointMake((self.pageControl.currentPage + 1)*self.scrollView.bounds.size.width, 0) animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_imageArray.count>1)
    {
        int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
        if (page == _imageArray.count+1)
        {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
            self.pageControl.currentPage = 0;
        }
        else if (page == 0)
        {
            scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width * _imageArray.count, 0);
            self.pageControl.currentPage = _imageArray.count-1;
        }
        else
        {
            self.pageControl.currentPage = page - 1;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

- (void)loadAdPage:(UITapGestureRecognizer *)tap
{
    if (!IsArrEmpty(_bannerFunctionIDArray)) {
        if (_bannerFunctionIDArray.count>=tap.view.tag+1) {
            //[[SOSReportService shareInstance] recordActionWithFunctionID:_bannerFunctionIDArray[tap.view.tag]];
        }
    }
    NNBanner *adModel = _imageArray[tap.view.tag];
    if (adModel.showType.integerValue == 3) {
        [self pushH5WebView:adModel];
    }
    else
    {
        SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:adModel.url];
        [self.viewCtrl.navigationController pushViewController:vc animated:YES];
    }
}
- (void)pushH5WebView:(NNBanner *)banner{
    
    SOSWebViewController *web = [SOSUtil generateBannerClickController:banner];
    [self.viewCtrl.navigationController pushViewController:web animated:YES];
}

- (void)dealloc
{
    _timer = nil;
}

@end
