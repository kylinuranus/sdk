//
//  SOSVehicleCashBookView
//  Onstar
//
//  Created by Genie Sun on 2017/8/8.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleCashBookView.h"
#import "SOSCardUtil.h"
@interface SOSVehicleCashBookView ()
@property (weak, nonatomic) IBOutlet UIView *monthlyView;
@property (weak, nonatomic) IBOutlet UIView *yearlyView;
@property (weak, nonatomic) IBOutlet UILabel *monthlyLabel;//月度
@property (weak, nonatomic) IBOutlet UILabel *yearlyLabel; //年度
@property (weak, nonatomic) IBOutlet UIImageView *exampleImgView;
@property (weak, nonatomic) IBOutlet UIView *iconView;

//@property (weak, nonatomic) IBOutlet UILabel *drivingInfoLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivingLabelCons;
//@property (weak, nonatomic) IBOutlet UIImageView *flagMaisui;
@end

@implementation SOSVehicleCashBookView
{
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initUI];
}
- (void)initUI{
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,66,66);
    gl.startPoint = CGPointMake(0.5, -0.56);
    gl.endPoint = CGPointMake(0.5, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:233/255.0 green:240/255.0 blue:254/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    [self.iconView.layer addSublayer:gl];
    self.iconView.layer.cornerRadius = 4;
    self.iconView.clipsToBounds = YES;
    
    [self.iconView setTapActionWithBlock:^{
        [SOSDaapManager sendActionInfo:ME_CASHFLOW_ADD];
        //账本
        SOSWebViewController* pushedCon = [[SOSWebViewController alloc] initWithUrl:VEHICLE_ACCOUNT_URL];
        [pushedCon setBackClickCompleteBlock:^{
            [SOSCardUtil shareInstance].vehicleCashBookResp = nil;
        }];
        [[LoginManage sharedInstance] setDependenceIllegal:![[LoginManage sharedInstance] isLoadingUserBasicInfoReadyOrUnLogin]];
        [SOSCardUtil routerToVc:pushedCon
                      checkAuth:YES
                     checkLogin:YES];
       
    }];
   
//    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(self);
////        make.centerY.mas_equalTo(self);
//        make.left.mas_equalTo(self.yearlyView.mas_right);
//        make.top.mas_equalTo(self.yearlyView);
//        make.bottom.mas_equalTo(self.yearlyView);
////        make.width.mas_equalTo(66);
////        make.height.mas_equalTo(66);
//    }];
//
    UIImageView * icon = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"icon_me_account_cashbook_record"]];
    [self.iconView addSubview:icon];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconView).offset(-8);
        make.centerX.mas_equalTo(self.iconView);
    }];

    UILabel * write = [[UILabel alloc] init];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"记一笔"attributes: @{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size: 12],NSForegroundColorAttributeName: [UIColor colorWithRed:158/255.0 green:176/255.0 blue:227/255.0 alpha:1.0]}];
    write.textAlignment = NSTextAlignmentCenter;
    write.attributedText = string;
    [self.iconView addSubview:write];
    [write mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.iconView);
        make.bottom.mas_equalTo(self.iconView.bottom).offset(-7);
    }];
   
}
- (void)refreshWithResponseData:(NNVehicleCashResp *)responseData
                         status:(RemoteControlStatus)status{
    if (status == RemoteControlStatus_OperateSuccess) {
//        if (responseData.recentUseFlag) {
//            self.drivingInfoLabel.text = @"安全驾驶表现";
        
        self.monthlyLabel.text = [self visiableNumber:responseData.multiMonthStatistics];
        self.yearlyLabel.text = [self visiableNumber:responseData.monthStatistics];
        self.exampleImgView.hidden = !responseData.demo;
//            self.exampleImgView.hidden = !responseData.mockFlag;
//            self.drivingLabelCons.constant = -10;
//            CGFloat animationValue = [responseData.score floatValue];
//            circle.animationValue = animationValue/100;
//            if (animationValue >= 80) {
//                circle.fillStrokeColor = [UIColor colorWithHexString:@"A0FFD4"];
//                _flagMaisui.image = [UIImage imageNamed:@"icon-maihui-you"];
//                self.yearlyLabel.text = responseData.scoreName?:@"优秀";
//            }else if (animationValue >40) {
//                circle.fillStrokeColor = [UIColor colorWithHexString:@"FFE994"];
//                _flagMaisui.image = [UIImage imageNamed:@"icon-maihui-zhong"];
//                self.yearlyLabel.text = responseData.scoreName?:@"良好";
//            }else {
//                circle.fillStrokeColor = [UIColor colorWithHexString:@"FF9EAA"];
//                _flagMaisui.image = [UIImage imageNamed:@"icon-maihui-cha"];
//                self.yearlyLabel.text = responseData.scoreName?:@"偏差";
//            }
//        }else {
//            self.monthlyLabel.text = @"--";
//            self.yearlyLabel.text = @"";
//            self.drivingInfoLabel.text = @"近期无驾驶记录";
//            self.yearlyLabel.text = @"";
//            self.drivingLabelCons.constant = 0;
//            self.exampleImgView.hidden = YES;
//            circle.animationValue = 0;
//            _flagMaisui.image = nil;
//        }
    }else {
        if (status == RemoteControlStatus_InitSuccess) {
                self.exampleImgView.hidden = YES;
                self.monthlyLabel.text = @"__";
                self.yearlyLabel.text =  @"__";
           
        }else{
            
        }
        
    }
}
- (NSString *)visiableNumber:(NSString *)number
{
    if (number) {
        if (number.length >= 9) {
            number = @"999999.9";
        }
        return number;
    }
    return @"0.0";
}
@end
