//
//  SOSVehicleInsuranceView.m
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleInsuranceView.h"
#import "UIImageView+Banner.h"
#import "TYCyclePagerView.h"
#import "SOSCardUtil.h"
#import "TYPageControl.h"
#import "SOSCycleBannerViewCell.h"
@interface SOSVehicleInsuranceView ()<TYCyclePagerViewDelegate, TYCyclePagerViewDataSource>
@property (weak, nonatomic) IBOutlet TYCyclePagerView *pageView;
@property (weak, nonatomic) IBOutlet TYPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *pageNumber;

@property (nonatomic, copy) NSArray *banners;

@end


@implementation SOSVehicleInsuranceView
- (void)awakeFromNib {
    [super awakeFromNib];

    [self.pageView registerClass:[SOSCycleBannerViewCell class] forCellWithReuseIdentifier:SOSBannerReuseIdentifier];
    self.pageView.isInfiniteLoop = YES;
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.autoScrollInterval = 3;
    self.pageView.layout.itemSize = CGSizeZero;
}


- (void)refreshWithBanners:(NSArray *)banners {
    
    if ([banners isKindOfClass:[NSArray class]] && banners.count > 0) {
        self.banners = banners;
    }else {
        self.banners = nil;
    }
//    self.pageControl.numberOfPages = self.banners.count;
    self.pageNumber.text = [NSString stringWithFormat:@"1/%ld", self.banners.count];
//    self.pageControl.hidesForSinglePage = YES;
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
//    return 0;
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
//        [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl] placeholder:nil];
//    }else {
//        cell.imageView.image = nil;
//    }
//    return cell;
//}
//
//#pragma mark - FSPagerView Delegate
//
//- (void)pagerView:(FSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
//{
//    [SOSDaapManager sendActionInfo:UBI_insurance_banner];
//    self.pageControl.currentPage = index;
//    [pagerView deselectItemAtIndex:index animated:YES];
//    [pagerView scrollToItemAtIndex:index animated:YES];
//    if (self.banners) {
//        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
//        bannerInfo.functionId = BANNER_HOME;
//        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:bannerInfo];
//        if (pushedCon) {
//            [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
//            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:pushedCon.topViewController animated:YES];
////            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:^{
////
////            }];
//        }
//    }
//
//}
//
//- (void)pagerViewDidScroll:(FSPagerView *)pagerView
//{
//    if (self.pageControl.currentPage != pagerView.currentIndex) {
//        self.pageControl.currentPage = pagerView.currentIndex;
//    }
//}
#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
        if (self.banners) {
            return self.banners.count;
        }
        return 0;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
        SOSCycleBannerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:SOSBannerReuseIdentifier forIndex:index];
    
        if (self.banners) {
            NNBanner *bannerInfo = [self.banners objectAtIndex:index];
            [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl] placeholder:nil];
        }else {
            cell.imageView.image = nil;
        }
        return cell;

}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    CGFloat width = kScreenWidth - 24;
//    if (self.banners.count == 1) {
//        //        layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame), CGRectGetHeight(pageView.frame));
//        layout.itemSize = CGSizeMake(width, CGRectGetHeight(pageView.frame));
//        layout.itemHorizontalCenter = YES;
//    }else{
//        layout.itemSpacing = 6;
        layout.itemSize = CGSizeMake(width, CGRectGetHeight(pageView.frame));
//    }
//    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame), CGRectGetHeight(pageView.frame));
//    layout.itemSpacing = 15;
    //layout.minimumAlpha = 0.3;
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didScrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    self.pageNumber.text = [NSString stringWithFormat:@"%ld/%ld", toIndex+1,self.banners.count];
}
- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index;
{
    [SOSDaapManager sendActionInfo:ME_UBI];
//    self.pageControl.currentPage = index;
    self.pageNumber.text = [NSString stringWithFormat:@"%ld/%ld", index+1,self.banners.count];

    if (self.banners) {
        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
        
        if ([bannerInfo.title containsString:@"里程"]) {
            [SOSCardUtil showMileAgeInsuranceStatementVCWithURL:bannerInfo.url FromVC:self.viewController Success:nil];
            return;
        }
        bannerInfo.functionId = BANNER_HOME;
        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:bannerInfo];
        if (pushedCon) {
            [SOSDaapManager sendSysBanner:bannerInfo.bannerID.stringValue funcId:SmartVehicle_banner];
//            [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
            [[SOS_APP_DELEGATE fetchMainNavigationController] pushViewController:pushedCon.topViewController animated:YES];
//            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:^{
//
//            }];
        }
    }

}
@end
