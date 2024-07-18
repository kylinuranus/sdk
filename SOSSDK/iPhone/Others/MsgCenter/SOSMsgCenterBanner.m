//
//  SOSMsgCenterBanner.m
//  Onstar
//
//  Created by WQ on 2018/5/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSMsgCenterBanner.h"
#import "UIImageView+Banner.h"
#import "TYCyclePagerView.h"
#import "TYPageControl.h"
#import "SOSCycleBannerViewCell.h"
@interface SOSMsgCenterBanner () <TYCyclePagerViewDelegate, TYCyclePagerViewDataSource>
@property (weak, nonatomic) IBOutlet TYCyclePagerView *pageView;
@property (nonatomic, copy) NSArray *banners;
@property (nonatomic, copy) NSArray *localImgs;
@property (nonatomic, copy) NSArray *localBanners;

@end


@implementation SOSMsgCenterBanner



- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.localImgs = @[@"homePage_banner_buick",
                       @"homePage_banner_cadillac",
                       @"homePage_banner_chevrolet"];
    [self.pageView registerClass:[SOSCycleBannerViewCell class] forCellWithReuseIdentifier:SOSBannerReuseIdentifier];
    self.pageView.isInfiniteLoop = YES;
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.autoScrollInterval = 3;
    self.pageView.layout.itemSize = CGSizeZero;
}

+ (SOSMsgCenterBanner*)instanceView
{
    NSArray *arr = [[NSBundle SOSBundle] loadNibNamed:@"SOSMsgCenterBanner" owner:self options:nil];
    return arr[0];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}



- (NSArray *)localBanners {

    if (!_localBanners) {
    //如果没有banner,显示默认的banner
    NSMutableArray *localBanner = @[].mutableCopy;
    for (int i =  0; i < 3; i++) {
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.image = [UIImage imageNamed:_localImgs[i]];
        [localBanner addObject:imageview];
    }
    _localBanners = localBanner.mutableCopy;
}
return _localBanners;

}

- (void)refreshWithBanners:(NSArray *)banners {
    
    if ([banners isKindOfClass:[NSArray class]] && banners.count > 0) {
        self.banners = banners;
    }else {
        self.banners = nil;
    }
    
    self.pageView.isInfiniteLoop = self.banners.count!=1;
    [self.pageView reloadData];
    
}


//#pragma mark - FSPagerViewDataSource
//
//- (NSInteger)numberOfItemsInPagerView:(FSPagerView *)pagerView
//{
//    if (self.banners) {
//        return self.banners.count;
//    }
//    return self.localBanners.count;
//
//}
//
//- (FSPagerViewCell *)pagerView:(FSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index
//{
//    FSPagerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
//    cell.imageView.contentMode = UIViewContentModeScaleToFill;
//    cell.imageView.clipsToBounds = YES;
//
//    if (self.banners) {
//        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
//        UIImage *placeHolder = [UIImage imageNamed:_localImgs[index%_localImgs.count]];
//        [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl] placeholder:placeHolder];
//    }else {
//        cell.imageView.image = [UIImage imageNamed:_localImgs[index]];
//    }
//    return cell;
//}
//
//#pragma mark - FSPagerView Delegate
//
//- (void)pagerView:(FSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
//{
//    [SOSDaapManager sendActionInfo:My_massage_banner];
//    [pagerView deselectItemAtIndex:index animated:YES];
//    [pagerView scrollToItemAtIndex:index animated:YES];
//    if (self.banners) {
//        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
//        bannerInfo.functionId = BANNER_HOME;
//        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:bannerInfo];
//        if (pushedCon) {
//            [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:^{
//
//            }];
//        }
//    }
//
//}

#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
        if (self.banners) {
            return self.banners.count;
        }
        return self.localBanners.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
        SOSCycleBannerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:SOSBannerReuseIdentifier forIndex:index];
    
        if (self.banners) {
            NNBanner *bannerInfo = [self.banners objectAtIndex:index];
            UIImage *placeHolder = [UIImage imageNamed:_localImgs[index%_localImgs.count]];
            [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl] placeholder:placeHolder];
        }else {
            cell.imageView.image = [UIImage imageNamed:_localImgs[index]];
        }
        return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame), CGRectGetHeight(pageView.frame));
//    layout.itemSpacing = 15;
    //layout.minimumAlpha = 0.3;
    return layout;
}
- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;
{
    [SOSDaapManager sendActionInfo:My_massage_banner];
//    [pagerView deselectItemAtIndex:index animated:YES];
//    [pagerView scrollToItemAtIndex:index animated:YES];
    if (self.banners) {
        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
        bannerInfo.functionId = BANNER_HOME;
        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:bannerInfo];
        if (pushedCon) {
            [SOSDaapManager sendSysBanner:bannerInfo.bannerID.stringValue funcId:SmartVehicle_banner];

//            [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:^{

            }];
        }
    }

}

@end
