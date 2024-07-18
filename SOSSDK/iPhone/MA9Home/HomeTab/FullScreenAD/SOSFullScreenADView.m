//
//  SOSFullScreenADView.m
//  Onstar
//
//  Created by TaoLiang on 2019/12/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSFullScreenADView.h"
#import "SOSEllipsePageControl.h"
#import "UIImageView+WebCache.h"

@interface SOSFullScreenADCell : UICollectionViewCell
- (void)setIconURL:(NSString *)iconUrl;
@end

@interface SOSFullScreenADCell ()
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation SOSFullScreenADCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setIconURL:(NSString *)iconUrl{
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:nil];
}



@end

@interface SOSFullScreenADView ()<EllipsePageControlDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) UIView *containerView;

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) SOSEllipsePageControl *pageControl;
@property (strong, nonatomic) YYTimer *timer;

@end

@implementation SOSFullScreenADView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
        
        UIView *containerView = UIView.new;
        containerView.backgroundColor = UIColor.whiteColor;
        containerView.layer.cornerRadius = 4;
        containerView.layer.masksToBounds = YES;
        [self addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make){
            make.size.mas_equalTo(CGSizeMake(270, 378));
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-20);
        }];
        _containerView = containerView;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        collectionView.scrollEnabled = NO;
        [collectionView registerClass:SOSFullScreenADCell.class forCellWithReuseIdentifier:SOSFullScreenADCell.className];
        [containerView addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make){
            make.edges.equalTo(containerView);
        }];
        _collectionView = collectionView;
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"Icon／54x54／icon_close_white_54x54"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(containerView);
            make.top.equalTo(containerView.mas_bottom).offset(20);
        }];
        
        SOSEllipsePageControl *pageControl = [[SOSEllipsePageControl alloc]init];
        pageControl.numberOfPages = 0;
        pageControl.currentPage = 0;
        pageControl.controlWidth = 6;
        pageControl.controlHeight = 2;
        pageControl.controlSpacing = 6;
        pageControl.currentColor = SOSUtil.defaultLabelLightBlue;
        pageControl.otherColor = [UIColor colorWithHexString:@"#C3CEEC"];
        pageControl.delegate = self;
        [self addSubview:pageControl];

        [pageControl mas_makeConstraints:^(MASConstraintMaker *make){
            make.centerX.equalTo(containerView);
            make.height.equalTo(@6);
            make.bottom.equalTo(containerView).offset(-15);
        }];
        _pageControl = pageControl;

        [self addTimer];
    }
    return self;
}

- (void)setBanners:(NSArray<NNBanner *> *)banners {
    _banners = banners;
    [_collectionView reloadData];
    _pageControl.numberOfPages = banners.count;
    
    CGFloat pageWidth = (_pageControl.numberOfPages - 1) * _pageControl.controlWidth + _pageControl.controlWidth * 2 + (_pageControl.numberOfPages - 1) * _pageControl.controlSpacing;
    [_pageControl mas_updateConstraints:^(MASConstraintMaker *make){
        make.width.mas_equalTo(pageWidth);
    }];

    if (banners.count > 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_banners.count * 100 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            [self addTimer];
        });
    }
}

- (void)show {
    [UIApplication.sharedApplication.keyWindow addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(UIApplication.sharedApplication.keyWindow);
    }];
    
    _containerView.alpha = 0.8;
    _containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _containerView.transform = CGAffineTransformIdentity;
        _containerView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)dismiss {
    _dismissed ? _dismissed() : nil;
    [self removeFromSuperview];
}

#pragma mark - flow layout delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return _collectionView.size;
}

#pragma mark - data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _banners.count == 1 ? 1 : _banners.count * 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NNBanner *banner = _banners[indexPath.row % _banners.count];
    SOSFullScreenADCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SOSFullScreenADCell.className forIndexPath:indexPath];
    [cell setIconURL:banner.imgUrl];
    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectBlock) {
        _selectBlock(indexPath.row % _banners.count);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _pageControl.currentPage = ((int)_collectionView.contentOffset.x / (int)_collectionView.frame.size.width) % _banners.count;
}



#pragma mark - EllipsePageControlDelegate
-(void)ellipsePageControlClick:(SOSEllipsePageControl*)pageControl index:(NSInteger)clickIndex {
    
}


#pragma mark - timer

- (void)addTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_banners.count == 1) {
        return;
    }
    _timer = [YYTimer timerWithTimeInterval:3 target:self selector:@selector(nextPage) repeats:YES];
    
}

// 定时器的内容
- (void)nextPage {
    if (_banners.count == 1) {
        return;
    }
    // 获取当前的 indexPath
    NSIndexPath *currentIndexPath = [[_collectionView indexPathsForVisibleItems] lastObject];
    NSInteger row = currentIndexPath.row;
    row++;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    
}

- (void)dealloc {
    NSLog(@"%@ has dealloced", self.className);
}

@end
