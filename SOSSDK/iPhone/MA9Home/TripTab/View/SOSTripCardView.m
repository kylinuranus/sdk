//
//  SOSTripCardView.m
//  Onstar
//
//  Created by Coir on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTripCardView.h"
#import "SOSCardUtil.h"

@interface SOSTripCardView ()
@property (weak, nonatomic) IBOutlet UIImageView *demoFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIView *drivingScoreBGView;
@property (weak, nonatomic) IBOutlet UIImageView *driveFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *driveScoreLabel;

@property (weak, nonatomic) IBOutlet UIView *oliAndEnergyBGView;
@property (weak, nonatomic) IBOutlet UILabel *oliAndEnergyLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankMsgLabel;

@property (weak, nonatomic) IBOutlet UIView *footprintBGView;
@property (weak, nonatomic) IBOutlet UILabel *cityCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *footCountLabel;

@property (weak, nonatomic) IBOutlet UILabel *loadingTextLabel;

@property (weak, nonatomic) IBOutlet UIView *errorCheckInBGView;
@property (weak, nonatomic) IBOutlet UILabel *errorTextLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailLabelLeadingGuide;
@end

@implementation SOSTripCardView

+ (instancetype)initWithCardType:(SOSTripCardType)type		{
    SOSTripCardView *view = [SOSTripCardView viewFromXib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(enterNextPage)];
    [view addGestureRecognizer:tap];
    view.cardType = type;
    return view;
}

- (void)setCardType:(SOSTripCardType)cardType	{
    if (_cardType == cardType) 		return;
    else	{
        _cardType = cardType;
        self.titleLabel.text = @[@"驾驶行为评价", @"能耗水平", @"我的足迹", @"油耗水平"][self.cardType - 1];
    }
}

- (void)setCardStatus:(SOSTripCardStatus)cardStatus		{
    if (_cardStatus == cardStatus || self.cardType == 0)	return;
    else	{
        _cardStatus = cardStatus;
        [self configSelfWithCardStatus];
    }
}

/// 通过 卡片状态 配置各种 View 显示与否
- (void)configSelfWithCardStatus    {
    NSString *detailStr = @"";
    UIView *resultView = nil;
    if (self.cardType == SOSTripCardType_OilLevel)    {
        resultView = _oliAndEnergyBGView;
    }    else    {
        resultView = @[_drivingScoreBGView, _oliAndEnergyBGView, _footprintBGView][self.cardType - 1];
    }
    float detailLabelLeading = 0;
    switch (self.cardStatus) {
        case SOSTripCardStatus_Loading:
            resultView.hidden = YES;
            self.errorCheckInBGView.hidden = YES;
            detailLabelLeading = 15.f;
            detailStr = @[@"查看我的驾驶行为分析、最近行程等信息。",
                          @"查看能耗水平和全国排名，体现我的低碳驾驶技术。",
                          @"我用车轮丈量过的地方。",
                          @"查看油耗水平和全国排名，体现我的低碳驾驶技术。"][self.cardType - 1];
            break;
        case SOSTripCardStatus_LoadDataError:
            resultView.hidden = YES;
            self.errorCheckInBGView.hidden = NO;
            self.errorTextLabel.text = @"加载失败，点击刷新";
            detailLabelLeading = 15.f;
            detailStr = @[@"查看我的驾驶行为分析、最近行程等信息。",
                          @"查看能耗水平和全国排名，体现我的低碳驾驶技术。",
                          @"我用车轮丈量过的地方。",
                          @"查看油耗水平和全国排名，体现我的低碳驾驶技术。"][self.cardType - 1];
            break;
        case SOSTripCardStatus_NoData:
            self.errorCheckInBGView.hidden = (self.cardType == SOSTripCardType_Footprint);
            self.errorTextLabel.text = @"暂无数据";
            resultView.hidden = (self.cardType != SOSTripCardType_Footprint);
            detailLabelLeading = 15.f;
            detailStr = @[@"查看我的驾驶行为分析、最近行程等信息。",
                          @"查看能耗水平和全国排名，体现我的低碳驾驶技术。",
                          @"到达过的城市有",
                          @"查看油耗水平和全国排名，体现我的低碳驾驶技术。"][self.cardType - 1];
            break;
        case SOSTripCardStatus_DemoData:
            resultView.hidden = NO;
            self.errorCheckInBGView.hidden = YES;
            detailLabelLeading = 5.f;
            detailStr = @[@"我的安全驾驶表现为",
                          @"近30天能耗水平",
                          @"到达过的城市有",
                          @"近 30 天油耗水平"][self.cardType - 1];
            break;
        case SOSTripCardStatus_LoadDataSuccess:
            resultView.hidden = NO;
            self.errorCheckInBGView.hidden = YES;
            detailLabelLeading = 5.f;
            detailStr = @[@"我的安全驾驶表现为",
                          @"",
                          @"到达过的城市有",
                          @""][self.cardType - 1];
            break;
        default:
            break;
    }
    self.detailLabel.text = detailStr;
    self.detailLabel.textAlignment = detailLabelLeading == 15 ? NSTextAlignmentLeft : NSTextAlignmentCenter;
    self.detailLabelLeadingGuide.constant = detailLabelLeading;
    self.loadingTextLabel.hidden = (self.cardStatus != SOSTripCardStatus_Loading);
    self.demoFlagImgView.hidden = (self.cardStatus != SOSTripCardStatus_DemoData);
    self.errorCheckInBGView.userInteractionEnabled = (self.cardStatus == SOSTripCardStatus_LoadDataError);
    [self layoutIfNeeded];
}

/// 配置数据显示
- (void)configSelfWithCardType:(SOSTripCardType)type AndData:(id)data	{
    self.cardType = type;
    switch (self.cardType) {
        case SOSTripCardType_DriveBehiver:
            if (![data isKindOfClass:[NNDrivingScoreResp class]])	return;
            [self configSelfWithDriveData:data];
            break;
        case SOSTripCardType_EnergyLevel:
            self.loadingTextLabel.text = @"加载中..";
            if (![data isKindOfClass:[NNEngrgyRankResp class]])    return;
            [self configSelfWithEnergyData:data];
            break;
        case SOSTripCardType_Footprint:
            if (![data isKindOfClass:[NSDictionary class]])    return;
            [self configSelfWithFootPrintData:data];
            break;
        case SOSTripCardType_OilLevel:
            if (![data isKindOfClass:[NNOilRankResp class]])    return;
            [self configSelfWithOliData:data];
            break;
        default:
            break;
    }
}

- (void)configSelfWithDriveData:(NNDrivingScoreResp *)data	{
    dispatch_async_on_main_queue(^{
        NSString *flagImgName = nil;
        if (data.recentUseFlag && ![data.score isEqualToString:@"--"]) {
            if (data.mockFlag.boolValue) {
                self.cardStatus = SOSTripCardStatus_DemoData;
                [SOSDaapManager sendActionInfo:SmartDriver_Demo];
            }	else	{
                self.cardStatus = SOSTripCardStatus_LoadDataSuccess;
                [SOSDaapManager sendActionInfo:SmartDriver_RealData];
            }
            float score = data.score.floatValue;
            if (score >= 80) {
                flagImgName = @"Trip_Card_Drive_Flag_Good";
                self.driveScoreLabel.textColor = [UIColor colorWithHexString:@"6CCA46"];
            }    else if (score >= 60)    {
                flagImgName = @"Trip_Card_Drive_Flag_Normal";
                self.driveScoreLabel.textColor = [UIColor colorWithHexString:@"F18F19"];
            }    else    {
                flagImgName = @"Trip_Card_Drive_Flag_Bad";
                self.driveScoreLabel.textColor = [UIColor colorWithHexString:@"C50000"];
            }
            self.driveFlagImgView.image = [UIImage imageNamed:flagImgName];
            self.driveScoreLabel.text = @(data.score.intValue).stringValue;
        }    else    {
            self.cardStatus = SOSTripCardStatus_NoData;
            [SOSDaapManager sendActionInfo:SmartDriver_NoData];
        }
    });
}

- (void)configSelfWithEnergyData:(NNEngrgyRankResp *)data    {
    dispatch_async_on_main_queue(^{
        if (data.recentUseFlag) {
            if (data.mockFlag.boolValue) {
                self.cardStatus = SOSTripCardStatus_DemoData;
                [SOSDaapManager sendActionInfo:EnergyEconomy_Demo];
            }    else    {
                self.cardStatus = SOSTripCardStatus_LoadDataSuccess;
                [SOSDaapManager sendActionInfo:EnergyEconomy_RealData];
            }
            [self configRankMsgWithMsg:data.rankMsg];
            self.resultUnitLabel.text = @"元 / 百公里";
            self.oliAndEnergyLevelLabel.text = data.costRatio;
        }	else	{
            self.cardStatus = SOSTripCardStatus_NoData;
            [SOSDaapManager sendActionInfo:EnergyEconomy_NoData];
        }
    });
}

- (void)configSelfWithOliData:(NNOilRankResp *)data    {
    dispatch_async_on_main_queue(^{
        if (data.recentUseFlag) {
            if (data.mockFlag.boolValue) {
                self.cardStatus = SOSTripCardStatus_DemoData;
                [SOSDaapManager sendActionInfo:FuelEconomy_Demo];
            }    else    {
                self.cardStatus = SOSTripCardStatus_LoadDataSuccess;
                [SOSDaapManager sendActionInfo:FuelEconomy_RealData];
            }
            [self configRankMsgWithMsg:data.rankMsg];
            self.resultUnitLabel.text = @"升 / 百公里";
            self.oliAndEnergyLevelLabel.text = data.fuelRatio;
        }    else    {
            self.cardStatus = SOSTripCardStatus_NoData;
            [SOSDaapManager sendActionInfo:FuelEconomy_NoData];
        }
    });
}

- (void)configRankMsgWithMsg:(NSString *)rankMsg	{
    if (rankMsg.length && [rankMsg containsString:@"\n"]) {
        NSArray *msgArr = [rankMsg componentsSeparatedByString:@"\n"];
        if (msgArr.count == 2) {
            NSString *str2 = msgArr[1];
            if ([str2 isEqualToString:@"未能入榜"])	self.rankMsgLabel.textColor = [UIColor colorWithHexString:@"CFCFCF"];
            else                                    self.rankMsgLabel.textColor = [UIColor colorWithHexString:@"6896ED"];
            self.detailLabel.text = msgArr[0];
            self.rankMsgLabel.text = str2;
        }
    }
}

- (void)configSelfWithFootPrintData:(NSMutableDictionary *)data    {
//    NSString *rank = @"0";
    NSInteger cityCount = 0;
    NSInteger footCount = 0;
    if (data.count) {
//        FootPrintPOI *poi = data.lastObject;
//        rank = poi.totalRank.stringValue;
        cityCount = [[data objectForKey:@"cityCount"] integerValue];
        footCount = [[data objectForKey:@"footprintCount"] integerValue];
    }
    self.cityCountLabel.text = @(cityCount).stringValue;
    NSString *resultStr = @"我还没有足迹";
    if (footCount || cityCount)		resultStr = [NSString stringWithFormat:@"共计%@条足迹",@(footCount)];
    self.footCountLabel.text = resultStr;
}

/// 卡片点击事件
- (void)enterNextPage	{
    // 排除 异常状态
    if (self.cardStatus == SOSTripCardStatus_Loading || self.cardStatus == SOSTripCardStatus_LoadDataError)		return;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardTappedWithCardView:)]) {
        __weak __typeof(self) weakSelf = self;
        [self.delegate cardTappedWithCardView:weakSelf];
    }
}

/// 数据加载失败,点击重新加载
- (IBAction)errorCheckInButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshCardButtonTappedWithCardView:)]) {
        __weak __typeof(self) weakSelf = self;
        [self.delegate refreshCardButtonTappedWithCardView:weakSelf];
    }
}

@end
