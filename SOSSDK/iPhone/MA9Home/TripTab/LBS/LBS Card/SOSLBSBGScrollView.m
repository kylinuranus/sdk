//
//  SOSLBSBGScrollView.m
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSLBSVerifyPasswordView.h"
#import "SOSLBSDetailCardView.h"
#import "SOSLBSBGScrollView.h"
#import "SOSLBSListCardView.h"
#import "SOSLBSHeader.h"

@interface SOSLBSBGScrollView ()	<SOSLBSListCardDelegate, SOSLBSDetailCardDelegate>

@property (nonatomic, strong) SOSLBSDataTool *lbsDataTool;

@property (nonatomic, strong) SOSLBSDetailCardView *detailCardView;

@property (nonatomic, strong) SOSLBSListCardView *selectedListCardView;

@property (nonatomic, assign) float detailOffsetX;

@end

@implementation SOSLBSBGScrollView

- (void)awakeFromNib	{
    [super awakeFromNib];
    [self addObserver];
    self.lbsDataTool = [SOSLBSDataTool new];
}

- (void)addObserver 	{
    __weak __typeof(self) weakSelf = self;
    /// LBS 设备删除
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:KSOSLBSInfoDeleteNoti object:nil] subscribeNext:^(NSNotification *noti) {
        NNLBSDadaInfo *tempLBSInfo = [noti.object copy];
        
        for (NNLBSDadaInfo *info in weakSelf.deviceList) {
            if ([info.deviceid isEqualToString:tempLBSInfo.deviceid]) {
                tempLBSInfo = info;
                break;
            }
        }
        [weakSelf.deviceList removeObject:tempLBSInfo];
        weakSelf.viewMode = SOSLBSBGViewMode_List;
        [weakSelf configSelfWithDeviceList];
    }];
    
    [[[LoginManage sharedInstance] rac_valuesAndChangesForKeyPath:@"loginState" options:NSKeyValueObservingOptionNew observer:self] subscribeNext:^(RACTwoTuple<id,NSDictionary *> *x) {
        id newValue = x.first;
        // 用户退出登录
        if ([newValue isKindOfClass:[NSNumber class]]) {
            LOGIN_STATE_TYPE newState = [newValue intValue];
            switch (newState) {
                case LOGIN_STATE_NON:    {
                    weakSelf.deviceList = nil;
                    weakSelf.viewMode = 0;
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

// 解决 Push 新页面时,系统调用此方法,导致莫名其妙的 ContentOffset 偏移问题, 勿删
- (void)_adjustContentOffsetIfNecessary    {
}

- (void)setViewMode:(SOSLBSBGViewMode)viewMode	{
    if (_viewMode == viewMode)		return;
    _viewMode = viewMode;
    [self configSelfWithViewMode];
}

- (void)configSelfWithViewMode	{
    switch (self.viewMode) {
        case SOSLBSBGViewMode_List:
            [self removeAllSubviews];
            self.selectedListCardView = nil;
            self.detailCardView = nil;
            self.contentSize = self.size;
            self.scrollEnabled = YES;
            // 获取过设备列表
            if (self.deviceList) {
                [self configSelfWithDeviceList];
            // 未获取过设备列表
            }    else    {
                SOSLBSListCardView *loadingCard = [self getNewCardWithCardStatus:SOSLBSListCardStatus_Loading];
                [self addSubview:loadingCard];
                [loadingCard mas_makeConstraints:^(MASConstraintMaker *make) {
                	make.left.equalTo(@(12));
                 	make.width.equalTo(@(150));
                 	make.top.equalTo(self);
                    make.height.equalTo(self);
                }];
                [self addBlankCardWithLastCard:loadingCard];
                [SOSLBSDataTool getUserLBSListSuccess:^(NSString *description, NSArray *resultArray) {
                    self.deviceList = [NSMutableArray arrayWithArray:resultArray];
                    [self configSelfWithDeviceList];
                } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
                    loadingCard.cardStatus = SOSLBSListCardStatus_Error;
                }];
            }
            break;
        case SOSLBSBGViewMode_Detail:
            break;
        default:
            break;
    }
}

- (SOSLBSListCardView *)addBlankCardWithLastCard:(UIView *)lastCard 	{
    SOSLBSListCardView *blankCard = [self getNewCardWithCardStatus:SOSLBSListCardStatus_Blank];
    [self addSubview:blankCard];
    [blankCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lastCard.mas_right).offset(12);
        make.width.equalTo(@(150));
        make.top.equalTo(self);
        make.height.equalTo(self);
    }];
    return blankCard;
}

- (void)configSelfWithDeviceList	{
    _viewMode = SOSLBSBGViewMode_List;
    [self.viewController performSelector:@selector(hideTopNavView:) withObject:@(NO) afterDelay:0];
    SOSLBSListCardView *loadingCard = nil;
    SOSLBSListCardView *blankCard = nil;
    for (SOSLBSListCardView *cardView in self.subviews) {
        if ([cardView isKindOfClass:[SOSLBSListCardView class]])    {
            if (cardView.cardStatus == SOSLBSListCardStatus_Loading) {
                loadingCard = cardView;
            }	else if (cardView.cardStatus == SOSLBSListCardStatus_Blank) {
                blankCard = cardView;
            }
        }	else	{
            [cardView removeFromSuperview];
        }
    }
    // 有设备
    if (self.deviceList.count) {
        [loadingCard removeFromSuperview];
        UIView *lastCardView = nil;
        for (int i = 0; i < self.deviceList.count; i++) {
            SOSLBSListCardView *card = [self getNewCardWithCardStatus:SOSLBSListCardStatus_Success];
            card.lbsInfo = self.deviceList[i];
            [self addSubview:card];
            [card mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastCardView)    {
                    make.left.mas_equalTo(lastCardView.mas_right).offset(12);
                }    else    {
                    make.left.equalTo(@(12));
                }
                make.width.equalTo(@(150));
                make.top.equalTo(self);
                make.height.equalTo(self);
            }];
            lastCardView = card;
        }
        if (blankCard)	{
            [blankCard mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(lastCardView.mas_right).offset(12);
            }];
        }	else	blankCard = [self addBlankCardWithLastCard:lastCardView];
        [self layoutIfNeeded];
        self.contentSize = CGSizeMake(blankCard.right + 12, self.height);
        self.contentOffset = CGPointMake(lastCardView.left, 0);
        [UIView animateWithDuration:.3 animations:^{
            [self setContentOffset:CGPointZero];
        }	completion:^(BOOL finished) {
            
        }];
    // 无设备
    }    else    {
        UIView *noDeviceView = [self getNoDeviceView];
        noDeviceView.alpha = .3;
        [UIView animateWithDuration:.2 animations:^{
            loadingCard.alpha = .3;
            loadingCard.width = self.width - 24;
            blankCard.left = loadingCard.right + 12;
        }	completion:^(BOOL finished) {
            [self removeAllSubviews];
            [self addSubview:noDeviceView];
            [UIView animateWithDuration:.1 animations:^{
                noDeviceView.alpha = 1;
            }];
        }];
    }
}

- (UIView *)getNoDeviceView	{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"安吉星“安星定位”服务，\n让你对家人的爱时时在线！"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Semibold" size: 17],NSForegroundColorAttributeName: [UIColor colorWithRed:40/255.0 green:41/255.0 blue:47/255.0 alpha:1.0]}];
    
    [string addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:104/255.0 green:150/255.0 blue:237/255.0 alpha:1.0]} range:NSMakeRange(3, 6)];
    
    UIView *noDeviceView = [[NSBundle SOSBundle] loadNibNamed:@"SOSLBSNoDeviceView" owner:self options:nil][0];
    UILabel *title = [noDeviceView viewWithTag:1234];
    [title setAttributedText:string];
    noDeviceView.frame = CGRectMake(12, 0, self.width - 24, 160);
    
    UIButton *addDeviceButton = [noDeviceView viewWithTag:1236];
    [[addDeviceButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [SOSDaapManager sendActionInfo:TRIP_LBS_ADDNEW];
        [self addLBSDeviceButtonTapped];
    }];
    
    return noDeviceView;
}

- (SOSLBSListCardView *)getNewCardWithCardStatus:(SOSLBSListCardStatus)status	{
    SOSLBSListCardView *card = [SOSLBSListCardView newCard];
    card.frame = CGRectMake(0, 0, 150, 160);
    card.cardStatus = status;
    card.delegate = self;
    return card;
}

#pragma mark - LBS List Card Delegate
/// 加载失败,重新加载
- (void)refreshLBSListButtonTapped		{
    [SOSDaapManager sendActionInfo:TRIP_LBS_RETEST];
    _viewMode = SOSLBSBGViewMode_List;
    SOSLBSListCardView *errorCard = nil;
    for (SOSLBSListCardView *cardView in self.subviews) {
        if ([cardView isKindOfClass:[SOSLBSListCardView class]])	{
            if (cardView.cardStatus == SOSLBSListCardStatus_Error) {
                errorCard = cardView;
            }
        }	else	{
            [cardView removeFromSuperview];
        }
    }
    // 从空白页跳转
    if (!errorCard) {
        self.deviceList = nil;
        [self configSelfWithViewMode];
    }
    errorCard.cardStatus = SOSLBSListCardStatus_Loading;
    [SOSLBSDataTool getUserLBSListSuccess:^(NSString *description, NSArray *resultArray) {
        self.deviceList = [NSMutableArray arrayWithArray:resultArray];
        [self configSelfWithDeviceList];
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        errorCard.cardStatus = SOSLBSListCardStatus_Error;
    }];
}

/// 添加设备
- (void)addLBSDeviceButtonTapped		{
    _viewMode = SOSLBSBGViewMode_List;
    SOSLBSAddDeviceVC *vc = [SOSLBSAddDeviceVC new];
    vc.stepType = SOSLBSAddDeviceStep_First;
    [vc setCompleteHanlder:^(NNLBSDadaInfo *newDevice) {
        [Util showSuccessHUDWithStatus:@"设备绑定成功"];
        [self refreshLBSListButtonTapped];
    }];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

/// 实时定位
- (void)getLBSLocationButtonTappedWithView:(SOSLBSListCardView *)view		{
    [self showLBSDetailCardWithView:view];
//9.2版本去除设备详情卡片的密码校验
/*  	NSNumber *loginFlag = [SOSLBSDataTool getSavedLoginFlagWithDeviceID:view.lbsInfo.deviceid];
    if (loginFlag == nil) {
        // 设备未登录,需要验证密码
        [self showCheckPassViewWithView:view];
    }   else    {
        if (loginFlag.boolValue == YES) {
            [self showLBSDetailCardWithView:view];
        }	else	{
            [self showCheckPassViewWithView:view];
        }
    }
}

- (void)showCheckPassViewWithView:(SOSLBSListCardView *)view	{
    SOSLBSVerifyPasswordView *verifyPassView = [SOSLBSVerifyPasswordView viewFromXib];
    verifyPassView.frame = self.viewController.view.bounds;
    [self.viewController.view addSubview:verifyPassView];
    __weak __typeof(self) weakSelf = self;
    [verifyPassView showViewWithLBSDataInfo:view.lbsInfo VerifyPassSuccessBlock:^{
        [weakSelf showLBSDetailCardWithView:view];
    }];		*/
}

- (void)showLBSDetailCardWithView:(SOSLBSListCardView *)view	{
    _viewMode = SOSLBSBGViewMode_Detail;
    [self.viewController performSelector:@selector(hideTopNavView:) withObject:@(YES) afterDelay:0];
    self.detailOffsetX = self.contentOffset.x;
    self.selectedListCardView = view;
    self.scrollEnabled = NO;
    self.detailCardView = [SOSLBSDetailCardView viewFromXib];
    self.detailCardView.delegate = self;
    __weak __typeof(self) weakSelf = self;
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(weakSelf.width - 12));
    }];
    [UIView animateWithDuration:.2 animations:^{
        [self layoutIfNeeded];
        view.alpha = .3;
        self.contentOffset = CGPointMake(view.left, 0);
    }    completion:^(BOOL finished) {
//        self.detailCardView.frame = CGRectMake(view.left + 12, 0, weakSelf.width - 24, weakSelf.height);
        self.detailCardView.alpha = .3;
        self.detailCardView.cardStatus = SOSLBSDetailCardStatus_Loading;
        [self addSubview:self.detailCardView];
        [self.detailCardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(12);
            make.top.equalTo(@(0));
            make.height.equalTo(@(weakSelf.height));
            make.width.equalTo(@(weakSelf.width - 24));
        }];
        [self layoutIfNeeded];
        
        [UIView animateWithDuration:.1 animations:^{
            self.detailCardView.alpha = 1;
            self.detailCardView.LBSInfo = view.lbsInfo;
            [self loadDatailCardData];
        }];
    }];
}

- (void)loadDatailCardData		{
    _viewMode = SOSLBSBGViewMode_Detail;
    [self.lbsDataTool getLBSPOIWithLBSDadaInfo:self.detailCardView.LBSInfo Success:^(SOSLBSPOI *lbsPOI) {
        if (!self.detailCardView)	return;
        self.detailCardView.cardStatus = SOSLBSDetailCardStatus_Success;
        self.detailCardView.LBSPOI = lbsPOI;
        if (self.cardDelegate && [self.cardDelegate respondsToSelector:@selector(showDetailCardWithLBSPOI:shouldUpdateMapView:)]) {
            [self.cardDelegate showDetailCardWithLBSPOI:lbsPOI shouldUpdateMapView:YES];
        }
    } Failure:^(NSInteger statusCode, NSString *responseStr, NSError *error) {
        self.detailCardView.cardStatus = SOSLBSDetailCardStatus_Error;
    }];
}

#pragma mark - LBS Detail Card Delegate
/// 用户点击重新加载
- (void)LBSDetailRefreshButtonTapped	{
    self.detailCardView.cardStatus = SOSLBSDetailCardStatus_Loading;
    [self loadDatailCardData];
}

/// 自动刷新完成回调
- (void)LBSDetailCardAutoRefreshedWithLBSPOI:(SOSLBSPOI *)lbsPOI	{
    if (self.cardDelegate && [self.cardDelegate respondsToSelector:@selector(showDetailCardWithLBSPOI:shouldUpdateMapView:)]) {
        [self.cardDelegate showDetailCardWithLBSPOI:lbsPOI shouldUpdateMapView:NO];
    }
}

/// 返回
- (void)LBSDetailBackButtonTapped	{
    _viewMode = SOSLBSBGViewMode_List;
    [self.viewController performSelector:@selector(hideTopNavView:) withObject:@(NO) afterDelay:0];
    // 同步设备信息变更
    if (self.detailCardView.shouldRefresh) {
        NNLBSDadaInfo *tempLBSInfo = [self.detailCardView.LBSInfo copy];
        for (int i = 0; i < self.deviceList.count; i++) {
            NNLBSDadaInfo *info = self.deviceList[i];
            if ([info.deviceid isEqualToString:tempLBSInfo.deviceid]) {
                [self.deviceList replaceObjectAtIndex:i withObject:tempLBSInfo];
                self.selectedListCardView.lbsInfo = tempLBSInfo;
                break;
            }
        }
    }
    
    [UIView animateWithDuration:.1 animations:^{
        self.detailCardView.alpha = .3;
    }    completion:^(BOOL finished) {
        [self.detailCardView removeFromSuperview];
        self.detailCardView = nil;
        [self.selectedListCardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(150));
        }];
        [UIView animateWithDuration:.2 animations:^{
            [self layoutIfNeeded];
            self.contentOffset = CGPointMake(self.detailOffsetX, 0);
            self.selectedListCardView.alpha = 1;
        }	completion:^(BOOL finished) {
            self.scrollEnabled = YES;
            self.selectedListCardView = nil;
        }];
    }];
}

@end
