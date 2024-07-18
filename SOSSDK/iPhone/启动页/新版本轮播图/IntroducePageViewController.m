//
//  IntroducePageViewController.m
//  Onstar
//
//  Created by Apple on 16/7/4.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "IntroducePageViewController.h"

@interface IntroducePageViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, assign) NSInteger pageNumber;
@property(strong, nonatomic)UIView *dotView;
@property(strong, nonatomic)UIImage *dotUnselectedImage;
@property(strong, nonatomic)UIImage *dotselectedImage;
@property (strong, nonatomic)NSMutableArray *dotImageViewArray;
@property (strong, nonatomic)UIButton *startBtn;
@end

@implementation IntroducePageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    NSArray *imageSeque = self.isPageGuideMode ? @[@"0", @"1", @"2", @"3", @"4"] : @[@"1", @"2", @"3", @"4"];
    _pageNumber = [imageSeque count];
    _imageArray = [[NSMutableArray alloc] init];

    self.dotselectedImage = [UIImage imageNamed:@"introduce_dot_selected"];
    self.dotUnselectedImage = [UIImage imageNamed:@"introduce_dot_unselected"];

    NSString *imageName = nil;
    CGFloat startY = 540;
    if (IS_IPHONE_XSeries) {
        if (self.isPageGuideMode) 	imageName = @"TL_Guide_X_%@";
        else						imageName = @"introduce_x_%@";
    }    else    {
        if (self.isPageGuideMode)   imageName = @"TL_Guide_%@";
        else                        imageName = @"introduce_4-0_%@";
    }
    
   	if (IS_IPHONE_5) {
        startY = 460;
    }	else	if (IS_IPHONE_6) {
        startY = 540;
    }	else	if (IS_IPHONE_6P) {
        startY = 594;
    }	else if (IS_IPHONE_XSeries) {
    }else{
        startY = 540;
    }

    for (NSString *index in imageSeque) {
        [_imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:imageName, index]]];
    }

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scroll];

    for (int i=0; i<_imageArray.count; i++)
    {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imgV.image = _imageArray[i];
        [scroll addSubview:imgV];
        if (self.isPageGuideMode) {
            __weak __typeof(self) weakSelf = self;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = [self getFrameWithIndex:i];
            [imgV addSubview:button];
            imgV.userInteractionEnabled = YES;
            [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                if (i == _imageArray.count - 1) {
                    [SOSDaapManager sendActionInfo:INTRODUCTION_PAGE5_GO];
                    [weakSelf enterApp];
                }	else	{
                    [scroll scrollRectToVisible:[scroll.subviews[i + 1] frame] animated:NO];
//                    [scroll setContentOffset:CGPointMake((i + 1) * SCREEN_HEIGHT, 0) animated:NO];
                }
            }];
            CGFloat statusBarH = [UIApplication sharedApplication].statusBarFrame.size.height;
            UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40 - 16, statusBarH, 40, 40)];
            skipButton.layer.cornerRadius = 20;
            skipButton.layer.masksToBounds = YES;
            skipButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
            [skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            skipButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            [skipButton setTitle:@"跳过" forState:UIControlStateNormal];
            [[skipButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
                NSString *recordStr = @[INTRODUCTION_PAGE1_SKIP, INTRODUCTION_PAGE2_SKIP, INTRODUCTION_PAGE3_SKIP, INTRODUCTION_PAGE4_SKIP, INTRODUCTION_PAGE5_SKIP][i];
                [SOSDaapManager sendActionInfo:recordStr];
                [weakSelf enterApp];
            }];
            [imgV addSubview:skipButton];
        }	else	{
            if (i == _imageArray.count -1) {
                _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _startBtn.backgroundColor = [UIColor clearColor];
                [_startBtn addTarget:self action:@selector(enterApp) forControlEvents:UIControlEventTouchUpInside];
                [imgV addSubview:_startBtn];
                imgV.userInteractionEnabled = YES;
                [_startBtn mas_makeConstraints:^(MASConstraintMaker *make){
                    make.centerX.equalTo(imgV);
                    make.bottom.equalTo(@-20);
                    make.size.mas_equalTo(CGSizeMake(140, 200));
                }];
                
            }
        }
    }
    scroll.scrollEnabled = !self.isPageGuideMode;
    scroll.contentSize = CGSizeMake(SCREEN_WIDTH*_imageArray.count, SCREEN_HEIGHT);
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.pagingEnabled = YES;
    scroll.bounces = NO;
    scroll.delegate = self;

    [self initDotView];
    
    self.showDot = NO;
}

- (CGRect)getFrameWithIndex:(int)index	{
    float beginX = 0;
    float beginY = 0;
    CGSize size = CGSizeMake(150.f * 375 / SCREEN_WIDTH, 45.f * 667 / SCREEN_HEIGHT);
    switch (index) {
        case 0:
            beginX = SCREEN_WIDTH / 2 - size.width / 2;
            if (IS_IPHONE_XSeries)        {
                beginY = 381.f / 812.f;
            }	else	{
                beginY = 304.5 / 667.f;
            }
            break;
        case 1:
            if (IS_IPHONE_XSeries)        {
                beginX = 113.f / 375.f * SCREEN_WIDTH;
                beginY = 559.f / 812.f;
            }    else    {
                beginX = 113.f / 375.f * SCREEN_WIDTH;
                beginY = 487.5 / 667.f;
            }
            break;
        case 2:
            beginX = SCREEN_WIDTH / 2 - size.width / 2;
            if (IS_IPHONE_XSeries)	{
                beginY = 248.f / 812.f;
            }    else    {
                beginY = 175.5 / 667.f;
            }
            break;
        case 3:
            if (IS_IPHONE_XSeries)        {
                beginX = 184.f / 375.f * SCREEN_WIDTH;
                beginY = 398.f / 812.f;
            }    else    {
                beginX = 184.f / 375.f * SCREEN_WIDTH;
                beginY = 322.5 / 667.f;
            }
            break;
        case 4:
            size = CGSizeMake(195.f * 375 / SCREEN_WIDTH, 45.f * 667 / SCREEN_HEIGHT);
            beginX = SCREEN_WIDTH / 2 - size.width / 2;
            if (IS_IPHONE_XSeries)        {
                beginY = 200 / 812.f;
            }    else    {
                beginY = 220 / 667.f;
            }
            break;
        default:
            break;
    }
    return CGRectMake(beginX, beginY * SCREEN_HEIGHT, size.width, size.height);
}

- (void)setShowDot:(BOOL)showDot {
    _showDot = showDot;
    _dotView.hidden = !showDot;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self refreshDotImageView:page];
}

- (void)enterApp	{
    if (_preOver) 	_preOver();
}

- (void)initDotView     {
    if (_dotView) {
        [_dotView removeFromSuperview];
    }

    CGFloat width = _dotselectedImage.size.width * _pageNumber+ (_pageNumber-1)*7;
    CGFloat height = _dotselectedImage.size.height;
    CGRect frame = CGRectMake(0, 0, width, height);

    _dotView = [[UIView alloc] initWithFrame:frame];
    CGPoint centerPoint = CGPointMake(self.view.center.x, self.view.frame.size.height-height-30);
    self.dotView.center = centerPoint;
    self.dotView.backgroundColor = [UIColor clearColor];

    _dotImageViewArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _pageNumber; i++) {
        CGFloat x = i * (_dotselectedImage.size.width+7) ;
        CGRect dotFrame = CGRectMake(x, 0, _dotselectedImage.size.width , _dotselectedImage.size.height);
        UIImageView *dotImageView = [[UIImageView alloc] initWithFrame:dotFrame];
        [dotImageView setContentMode:UIViewContentModeCenter];
        if (i == 0) {
            [dotImageView setImage:_dotselectedImage];
        }else {
            [dotImageView setImage:_dotUnselectedImage];
        }
        [_dotImageViewArray addObject:dotImageView];
        [self.dotView addSubview:dotImageView];
    }

    if (_pageNumber > 1) {
        [self.view addSubview:_dotView];
        [self.view bringSubviewToFront:_dotView];
    }
}

- (void)refreshDotImageView:(NSInteger)page{
    for (NSInteger i=0;i<_pageNumber;i++) {
        UIImageView *dotImageView = _dotImageViewArray[i];
        [dotImageView setImage:_dotUnselectedImage];
        if (page==i) {
            [dotImageView setImage:_dotselectedImage];
        }
    }
}

@end
