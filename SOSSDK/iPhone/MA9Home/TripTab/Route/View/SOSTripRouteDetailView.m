//
//  SOSTripRouteDetailView.m
//  Onstar
//
//  Created by Coir on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripRouteDetailView.h"
#import "SOSRouteInfoView.h"

@interface SOSTripRouteDetailView () <SOSRouteInfoViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *successBGView;
@property (weak, nonatomic) IBOutlet UIView *routeInfoBGView;
@property (weak, nonatomic) IBOutlet UIView *unNormalBGView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property (weak, nonatomic) SOSRouteInfoView *selectedView;
@property (weak, nonatomic) IBOutlet UIButton *navigateButton;
@property (weak, nonatomic) IBOutlet UIButton *carRemoteButton;

@end

@implementation SOSTripRouteDetailView

- (void)setCardStatus:(SOSRouteCardStatus)cardStatus	{
    _cardStatus = cardStatus;
    BOOL isSuccess = NO;
    BOOL shouldReload = NO;
    NSString *imgName = nil;
    NSString *detailTitle = nil;
    switch (cardStatus) {
        case SOSRouteCardStatus_Loading:
            imgName = @"Trip_LBS_List_Loading";
            detailTitle = @"正在计算路线..";
            break;
        case SOSRouteCardStatus_Fail:
            imgName = @"Trip_LBS_List_Reload";
            detailTitle = @"点击重新加载";
            shouldReload = YES;
            break;
        case SOSRouteCardStatus_UnReachable:
            imgName = @"Trip_Route_UnReachable";
            detailTitle = @"路径规划失败";
            
            break;
        case SOSRouteCardStatus_Success_Walk:
        case SOSRouteCardStatus_Success_Drive:
        case SOSRouteCardStatus_Success_Walk_Only:
            isSuccess = YES;
            break;
            
        default:
            break;
    }
    dispatch_async_on_main_queue(^{
        if (isSuccess) {
            self.unNormalBGView.hidden = YES;
            self.successBGView.hidden = NO;
            [self configRouteInfoViewWithCardStatus:cardStatus];
        }	else	{
            self.unNormalBGView.hidden = NO;
            self.successBGView.hidden = YES;
            self.reloadButton.userInteractionEnabled = shouldReload;
            self.statusImgView.image = [UIImage imageNamed:imgName];
            self.detailTextLabel.text = detailTitle;
        }
        cardStatus == SOSRouteCardStatus_Loading ? [self.statusImgView startRotating] : [self.statusImgView endRotating];
    });
}

- (void)configRouteInfoViewWithCardStatus:(SOSRouteCardStatus)cardStatus		{
    [self.routeInfoBGView removeAllSubviews];
    NSArray *titleStrArray;
    switch (cardStatus) {
        case SOSRouteCardStatus_Success_Drive:
            titleStrArray = @[@"最快", @"路程短", @"不走高速"];
            break;
        case SOSRouteCardStatus_Success_Walk:
            titleStrArray = @[@"步行", @"驾车"];
            break;
        case SOSRouteCardStatus_Success_Walk_Only:
            titleStrArray = @[@"步行", @""];	// 使用空Title占位,后续View隐藏
            break;
        default:
            break;
    }
    float viewWidth = (self.routeInfoBGView.width - 10 * (titleStrArray.count - 1)) / titleStrArray.count;
    for (int i = 0; i < titleStrArray.count; i++) {
        SOSRouteInfoView *view = [SOSRouteInfoView viewFromXib];
        view.frame = CGRectMake(i * (viewWidth + 10), 0, viewWidth, self.routeInfoBGView.height);
        view.title = titleStrArray[i];
        if (i == 0) {
            self.selectedView = view;
            view.viewHilighted = YES;
        }	else		view.viewHilighted = NO;
        view.delegate = self;
        [self.routeInfoBGView addSubview:view];
    }
}

- (void)configViewWithStrategy:(DriveStrategy)strategy AndRouteInfo:(SOSRouteInfo *)routeInfo	{
    [self configViewWithStrategy:strategy AndRouteInfo:routeInfo shouldHighlighted:NO];
}

- (void)configViewWithStrategy:(DriveStrategy)strategy AndRouteInfo:(SOSRouteInfo *)routeInfo shouldHighlighted:(BOOL)highlight	{
    SOSRouteInfoView *view = nil;
    NSArray *viewArray = self.routeInfoBGView.subviews;
    switch (strategy) {
        case DriveStrategyTimeFirst:
            view = (_cardStatus == SOSRouteCardStatus_Success_Drive) ? viewArray[0] : viewArray[1];
            break;
        case DriveStrategyDestanceFirst:
            view = viewArray[1];
            break;
        case DriveStrategyNoExpressWay:
            view = viewArray[2];
            break;
        case DriveStrategyWalk:
            view = viewArray[0];
            break;
        default:
            break;
    }
    view.routeInfo = routeInfo;
    if (highlight)	view.viewHilighted = highlight;
}

- (void)setIsFindCarMode:(BOOL)isFindCarMode	{
    _isFindCarMode = isFindCarMode;
    dispatch_async_on_main_queue(^{
        self.carRemoteButton.hidden = !isFindCarMode;
    });
}

- (void)viewTappedWithView:(SOSRouteInfoView *)view	{
    NSArray *viewArray = self.routeInfoBGView.subviews;
    for (SOSRouteInfoView *tempView in viewArray) {
        if (tempView.viewHilighted)	tempView.viewHilighted = NO;
    }
    self.selectedView = view;
    view.viewHilighted = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(routeChangedWithStrategy:)]) {
        [self.delegate routeChangedWithStrategy:view.routeInfo.strategy];
    }
}
- (IBAction)beginGPS {
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginGPSWithStrategy:)]) {
        [self.delegate beginGPSWithStrategy:self.selectedView.routeInfo.strategy];
    }
}

- (IBAction)reloadButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(failReloadButtonTapped)]) {
        [self.delegate failReloadButtonTapped];
    }
}
- (IBAction)carRemoteButtonTapped {
    self.carRemoteButton.selected = !self.carRemoteButton.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(showCarRemoteView:)]) {
        [self.delegate showCarRemoteView:self.carRemoteButton.isSelected];
    }
}

@end
