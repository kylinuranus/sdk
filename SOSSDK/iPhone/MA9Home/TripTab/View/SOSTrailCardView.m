//
//  SOSTrailCardView.m
//  Onstar
//
//  Created by Coir on 2019/10/9.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTrailCardView.h"

@interface SOSTrailCardView ()

@property (weak, nonatomic) IBOutlet UIImageView *demoFlagImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;


@property (weak, nonatomic) IBOutlet UIView *trailInfoBGView;
@property (weak, nonatomic) IBOutlet UIView *beginFlagView;
@property (weak, nonatomic) IBOutlet UIView *endFlagView;
@property (weak, nonatomic) IBOutlet UILabel *beginTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *resultBGView;
@property (weak, nonatomic) IBOutlet UILabel *trailLengthLabel;

@property (weak, nonatomic) IBOutlet UILabel *loadingTextLabel;
@property (weak, nonatomic) IBOutlet UIView *errorCheckInBGView;

@property (strong, nonatomic) UIView *dashLine;

@end

@implementation SOSTrailCardView

- (void)awakeFromNib    {
    [super awakeFromNib];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterNextPage)];
    [self addGestureRecognizer:tap];
}

- (void)setCardStatus:(SOSTripCardStatus)cardStatus		{
    _cardStatus = cardStatus;
    switch (cardStatus) {
        case SOSTripCardStatus_Loading:
            self.dashLine.hidden = YES;
            self.detailLabel.hidden = NO;
            self.resultBGView.hidden = YES;
            self.trailInfoBGView.hidden = YES;
            break;
        case SOSTripCardStatus_LoadDataError:
            self.dashLine.hidden = YES;
            self.detailLabel.hidden = NO;
            self.resultBGView.hidden = YES;
            self.trailInfoBGView.hidden = YES;
            break;
        case SOSTripCardStatus_NoData:
            self.dashLine.hidden = YES;
            self.detailLabel.hidden = NO;
            self.resultBGView.hidden = NO;
            self.trailInfoBGView.hidden = YES;
            break;
        case SOSTripCardStatus_DemoData:
            self.detailLabel.hidden = YES;
            self.resultBGView.hidden = NO;
            self.trailInfoBGView.hidden = NO;
            [self drawDashLine];
            break;
        case SOSTripCardStatus_LoadDataSuccess:
            self.detailLabel.hidden = YES;
            self.resultBGView.hidden = NO;
            self.trailInfoBGView.hidden = NO;
            [self drawDashLine];
            break;
        default:
            break;
    }
    self.loadingTextLabel.hidden = (self.cardStatus != SOSTripCardStatus_Loading);
    self.errorCheckInBGView.hidden = (self.cardStatus != SOSTripCardStatus_LoadDataError);
    self.demoFlagImgView.hidden = (self.cardStatus != SOSTripCardStatus_DemoData);
    self.errorCheckInBGView.userInteractionEnabled = (self.cardStatus == SOSTripCardStatus_LoadDataError);
    [self layoutIfNeeded];
}

- (void)setData:(SOSTrailResp *)data	{
    _data = data;
    if (data) {
        NSDictionary *dic = data.data;
        if ([dic isKindOfClass:[NSDictionary class]] && dic.count) {
            if (data.mockFlag.boolValue)    {
                self.cardStatus = SOSTripCardStatus_DemoData;
                [SOSDaapManager sendActionInfo:RecentTrip_Demo];
            }	else if (data.recentUseFlag)	{
                self.cardStatus = SOSTripCardStatus_LoadDataSuccess;
                [SOSDaapManager sendActionInfo:RecentTrip_RealData];
            }	else if (data.recentUseFlag == NO)	{
                self.cardStatus = SOSTripCardStatus_NoData;
                self.trailLengthLabel.text = @"0";
                [SOSDaapManager sendActionInfo:RecentTrip_NoData];
                return;
            }

            NSString *beginAddress = dic[@"ignitionPOI"];
            NSString *endAddress = dic[@"parkPOI"];
            NSNumber *trailLength = dic[@"tripMileage"];
            float floatLength = 0;
            if ([trailLength isKindOfClass:[NSNumber class]]) {
                floatLength = trailLength.floatValue / 1000.f;
            }
            self.beginTitleLabel.text = beginAddress;
            self.endTitleLabel.text = endAddress;
            self.trailLengthLabel.text = floatLength < 0.1 ? @"0" : [NSString stringWithFormat:@"%.1f", floatLength];
        }	else	{
            self.cardStatus = SOSTripCardStatus_NoData;
            self.trailLengthLabel.text = @"0";
        }
    }
}

- (void)drawDashLine {
    [_dashLine removeFromSuperview];
    _dashLine = [UIView new];
    [self addSubview:_dashLine];
    [_dashLine mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(_beginFlagView);
        make.top.equalTo(_beginFlagView.mas_bottom);
        make.bottom.equalTo(_endFlagView.mas_top);
        make.width.equalTo(@1);
    }];
    [self layoutIfNeeded];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.bounds = _dashLine.bounds;
    shapeLayer.position = CGPointMake(_dashLine.width, _dashLine.height / 2);
    shapeLayer.fillColor = UIColor.clearColor.CGColor;
    shapeLayer.strokeColor = [UIColor colorWithHexString:@"CFCFCF"].CGColor;
    shapeLayer.lineWidth = 1;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = @[@1, @1.5];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, _dashLine.height);
    
    shapeLayer.path = path;
    CGPathRelease(path);
    [_dashLine.layer addSublayer:shapeLayer];
}

/// 卡片点击事件
- (void)enterNextPage    {
    // 排除 异常状态
    if (self.cardStatus == SOSTripCardStatus_Loading || self.cardStatus == SOSTripCardStatus_LoadDataError)        return;
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
