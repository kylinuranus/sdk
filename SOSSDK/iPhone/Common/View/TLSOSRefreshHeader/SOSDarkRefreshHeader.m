//
//  SOSDarkRefreshHeader.m
//  Onstar
//
//  Created by TaoLiang on 2019/1/18.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSDarkRefreshHeader.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

typedef NS_ENUM(NSUInteger, CarPosition) {
    Begin,
    Middle,
    Final
};

@interface SOSDarkRefreshHeader ()
@property (weak ,nonatomic) UIImageView *bgGIF;
@property (weak, nonatomic) UIImageView *car;
@property (assign, nonatomic) CGFloat carPositionBegin;
@property (assign, nonatomic) CGFloat carPositionMiddle;
@property (assign, nonatomic) CGFloat carPositionFinal;

@end

@implementation SOSDarkRefreshHeader


static CGFloat kRefreshHeight = 80.f;
static CGFloat carHeight = 24.f;
static CGFloat carWidth = 88.f;


- (void)prepare{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = kRefreshHeight;
    self.clipsToBounds = YES;
    
    
    NSString *path = [[NSBundle SOSBundle] pathForResource:@"pull_refresh_night_MA9_0" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
    image.frameCacheSizeMax = 5;
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];
    
    _bgGIF = imageView;
    
    _carPositionMiddle = SCREEN_WIDTH / 2 - carWidth / 2 - 10;
    _carPositionBegin = -carWidth;
    
    
    UIImageView *car = [UIImageView new];
    car.image = [UIImage imageNamed:@"refresh_car_night"];
    [self addSubview:car];
    
    car.frame = CGRectMake(_carPositionBegin, kRefreshHeight / 2 - carHeight / 2 + 20, carWidth, carHeight);
    //    car.frame = CGRectMake(_carPositionBegin, kRefreshHeight - carHeight, carWidth, carHeight);
    
    _car = car;
    
    
}

- (void)placeSubviews{
    [super placeSubviews];
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
}


#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state{
    MJRefreshCheckState;
    
    if (state == MJRefreshStatePulling) {
        [self placeCar:Middle];
    }else if (state == MJRefreshStateRefreshing) {
        [self placeCar:Middle];
    }
    
    //    switch (state) {
    //        case MJRefreshStateIdle:{
    //            break;
    //
    //        }
    //        case MJRefreshStatePulling:
    //        {
    //            [self placeCar:Middle];
    //
    //            break;
    //        }
    //        case MJRefreshStateRefreshing:
    //        {
    //            [self placeCar:Middle];
    //
    //            break;
    //        }
    //        default:
    //            break;
    //    }
}


#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent{
    [super setPullingPercent:pullingPercent];
    
    if (pullingPercent <= 1) {
        _car.x = ( _carPositionMiddle + fabs(_carPositionBegin) ) * pullingPercent - fabs(_carPositionBegin);
    }
}


#pragma mark - car position

- (void)placeCar:(CarPosition)carPosition{
    switch (carPosition) {
        case Begin:
            _car.x = _carPositionBegin;
            break;
        case Middle:
            _car.x = _carPositionMiddle;
            break;
        case Final:
            _car.x = SCREEN_WIDTH;
        default:
            break;
    }
}

- (void)endRefreshing{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self placeCar:Final];
    } completion:^(BOOL finished) {
        [super endRefreshing];
        [self placeCar:Begin];
    }];
}

@end
