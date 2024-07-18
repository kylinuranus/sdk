//
//  SOSBannerTableViewCell.m
//  Onstar
//
//  Created by Genie Sun on 2017/9/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSBannerTableViewCell.h"
#import "UIImageView+Banner.h"
//#import "OnStar-Swift.h"
#import "TYCyclePagerView.h"
#import "TYPageControl.h"
#import "SOSCycleBannerViewCell.h"
#import "SOSCardUtil.h"





@interface SOSBannerTableViewCell ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>
@property (strong, nonatomic) TYCyclePagerView *pageView;
@property (nonatomic, copy) NSArray *banners;
@property (nonatomic, copy) NSArray *localImgs;
//@property (nonatomic, copy) NSArray *localBanners;

@end

@implementation SOSBannerTableViewCell

- (void)initViews {
    self.localImgs = @[@"homePage_banner_buick",
                       @"homePage_banner_cadillac",
                       @"homePage_banner_chevrolet"];
    self.pageView = [[TYCyclePagerView alloc] init];
    [self.contentView addSubview:_pageView];
    self.contentView.backgroundColor = [SOSUtil onstarLightGray];;
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.edges.mas_equalTo(self.contentView);
        make.height.mas_equalTo((80.f/(375-24))*(SCREEN_WIDTH -24));
    }];
    [self.pageView registerClass:[SOSCycleBannerViewCell class] forCellWithReuseIdentifier:SOSBannerReuseIdentifier];
    self.pageView.isInfiniteLoop = YES;
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    self.pageView.autoScrollInterval = 3;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)refreshWithBanners:(NSArray *)banners {
    self.banners = banners;
    self.pageView.isInfiniteLoop = self.banners.count!=1;
    [self.pageView reloadData];
    
}

#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.banners.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    SOSCycleBannerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:SOSBannerReuseIdentifier forIndex:index];
    NNBanner *bannerInfo = [self.banners objectAtIndex:index];
    UIImage *placeHolder = [UIImage imageNamed:_localImgs[index%_localImgs.count]];
//    [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl] placeholder:placeHolder];
    @weakify(self)
    [cell.imageView setImageWithURL:[NSURL URLWithString: bannerInfo.imgUrl]
                        placeholder:placeHolder options:kNilOptions completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                            @strongify(self)
                            !self.imageEndLoadBlock?:self.imageEndLoadBlock(error);
                        }];
    cell.imageView.layer.cornerRadius = 5;
    if (self.banners.count > 1) {
        cell.indexLabel.text = [NSString stringWithFormat:@" %ld / %ld ",index+1,self.banners.count];
    }
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    CGFloat width = kScreenWidth - 24;
    if (self.banners.count == 1) {
        //        layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame), CGRectGetHeight(pageView.frame));
        layout.itemSize = CGSizeMake(width, CGRectGetHeight(pageView.frame));
        layout.itemHorizontalCenter = YES;
    }else{
        layout.itemSpacing = 6;
        layout.itemSize = CGSizeMake(width, CGRectGetHeight(pageView.frame));
    }
    
    
    
    return layout;
}
- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index	{
    if (self.banners) {
        
        NNBanner *bannerInfo = [self.banners objectAtIndex:index];
        bannerInfo.functionId = BANNER_HOME;
        // 积分公益 Banner
        if ([bannerInfo.partnerId isEqualToString:@"welfare"])	{
            [SOSDaapManager sendActionInfo:SmartVehicle_IntegralCommonweal_Banner];
        }
        if ([bannerInfo.title containsString:@"里程"]) {
            [SOSCardUtil showMileAgeInsuranceStatementVCWithURL:bannerInfo.url FromVC:self.viewController Success:nil];
            return;
        }
        CustomNavigationController * pushedCon =[SOSUtil bannerClickShowController:bannerInfo];
        if (pushedCon) {
//            [[SOSReportService shareInstance] recordBannerActionWithFunctionIDMA80:SmartVehicle_banner objectID:bannerInfo.bannerID.stringValue];
            [SOSDaapManager sendSysBanner:bannerInfo.bannerID.stringValue funcId:SMARTVEHICLE_BANNER];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pushedCon animated:YES completion:^{
                
            }];
        }
    }
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}




@end
