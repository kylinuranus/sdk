//
//  SOSVehicleTabHeaderView.m
//  Onstar
//
//  Created by Onstar on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSVehicleTabHeaderView.h"
#import "SOSHorizontalMenuView.h"
#import "SOSQuickStartEditorViewController.h"
#import "SOSQuickStartHelper.h"
#import "SOSSexangleView.h"
#import "SOSAvatarManager.h"
#import "SOSCardUtil.h"
#import "SOSGotoVehicleConditionView.h"
#import "SOSVehicleLocationStatusView.h"
#import "SOSGreetingManager.h"
#import "UIImage+SOSSkin.h"

typedef NS_ENUM(NSInteger, SOSVehicleHeaderButtonType) {
    SOSVehicleHeaderButtonTypeLogin,   //登录
    SOSVehicleHeaderButtonTypeUpgradeSub //升级车主
    
};
@interface SOSVehicleTabHeaderView ()<FMHorizontalMenuViewDelegate,FMHorizontalMenuViewDataSource,SOSQuickStarteditCompleteDelegate>{
    UIView * totalBaseView; //总背景
    SOSSexangleView * sexangleProgress; //sexangle进度
    UIImageView * phevBackgroundImage;// phevBackgroundImage | sexangleProgress
    UIImageView * chargeStateImage;//
    CGFloat areaVeConWidth;
    UILabel * greetingLabel;
    SOSVehicleHeaderButtonType buttonType;
}

@property (strong, nonatomic) UIButton *overallScanBtn;

@property (nonatomic,strong) SOSHorizontalMenuView *quickStartView;
@property (nonatomic,strong) UIImageView *backgroundImageV;
@property (nonatomic,strong) UILabel *promptLabel;//提示
@property (nonatomic,strong) UILabel *meterLabel;//续航里程数
@property (nonatomic,strong) UILabel *enduranceLabel;//续航文字
@property (nonatomic,strong) UILabel *kmLabel;//“km”
@property (nonatomic,strong) UIButton *loginButton;//
@property (nonatomic,strong) UIView *areaPrompt;//第一区域 提示区域
@property (nonatomic,strong) UIView *areaVeCon;//第二区域 车况区域
@property (nonatomic,assign) SOSVehicleHeaderState state;

@property (nonatomic, assign) SOSRemoteOperationType operationingType;
@property (nonatomic, assign) RemoteControlStatus RemoteControlStatus;

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) CAGradientLayer *bgLayer;

@end
static const CGFloat defaultVeWidth = 150.0f;
@implementation SOSVehicleTabHeaderView
objection_register(SOSVehicleTabHeaderView);
//objection_initializer(initWithFrame:);
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initView];
        [self addObserver];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bgLayer.frame = self.bounds;
}

- (CALayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = CAGradientLayer.new;
        _bgLayer.colors = @[(__bridge id)UIColor.whiteColor.CGColor, (__bridge id)SOSUtil.onstarLightGray.CGColor];
        _bgLayer.startPoint = CGPointMake(0.0, 0.0);
        _bgLayer.endPoint = CGPointMake(0.0, 1);
        _bgLayer.locations = @[@(0.6), @(1)];
        [_bgView.layer addSublayer:_bgLayer];
    }
    return _bgLayer;
}

- (void)initView{
    
    _bgView = UIView.new;
    [self addSubview:_bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self);
    }];

    
    areaVeConWidth = SCALE_WIDTH(defaultVeWidth);
    //车况背景图
    totalBaseView = [[UIView alloc] init];
    [self addSubview:totalBaseView];
    //test
    //    totalBaseView.backgroundColor = [UIColor greenColor];
    [totalBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(@0);
        make.height.mas_equalTo(self).multipliedBy(0.67);
    }];
    if (!greetingLabel) {
        greetingLabel = [[UILabel alloc] init];
        greetingLabel.font =[UIFont fontWithName:@"PingFangSC-Medium" size: 15];
        greetingLabel.textColor = [UIColor whiteColor];
        [totalBaseView addSubview:greetingLabel];
        [greetingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(Util.isiPhoneXSeries ?20.0f:12.0f);
            make.top.mas_equalTo(Util.isiPhoneXSeries ? STATUSBAR_HEIGHT : STATUSBAR_HEIGHT + 5);
        }];
    }
    if (!SOS_BUICK_PRODUCT) {
        //快捷键
           self.quickStartView = [[SOSHorizontalMenuView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 140)];
           self.quickStartView.delegate = self;
           self.quickStartView.dataSource = self;
           //    self.quickStartView.backgroundColor = [UIColor redColor];
        if (SOS_CD_PRODUCT) {
            self.quickStartView.currentPageDotColor = [UIColor cadiStytle];
        }
           [self addSubview:self.quickStartView];
           [self.quickStartView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.leading.mas_equalTo(self);
               make.trailing.mas_equalTo(self);
               make.top.mas_equalTo(totalBaseView.mas_bottom);
               make.bottom.mas_equalTo(self).mas_offset(-15.0f);
           }];
           [self.quickStartView reloadData];
    }else{
        
    }
#if __has_include("SOSSDK.h")
    [self baseViewUnloginState];
    NSString *imageName = [NSString stringWithFormat:@"VehicleAvatar_%@_%@_Placeholder", @"UNSIGNIN", @"HOMEPAGE"];
    self.backgroundImageV.image =  [UIImage imageNamed:imageName];
    [self reloadQuickStartView];
#endif
    
}
-(CGFloat)quickStartHeight{
    return self.quickStartView.height;
}
- (void)addObserver {
    @weakify(self);
    [RACObserve([LoginManage sharedInstance] , loginState) subscribeNext:^(NSNumber *state) {
        @strongify(self)
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (state.integerValue == LOGIN_STATE_NON){
                //刷新未登录状态
                [self baseViewUnloginState];
                [self reloadQuickStartView];
            }
            if (state.integerValue == LOGIN_STATE_LOADINGTOKEN){
                //刷新未登录状态
                [self baseViewInloginState];
            }
            
            if (state.integerValue == LOGIN_STATE_LOADINGUSERBASICINFOSUCCESS) {
                [self reloadQuickStartView];
            }
            
            if (state.integerValue == LOGIN_STATE_LOADINGVEHICLECOMMANDSESUCCESS) {
                //刷新commands后状态
                [self reloadQuickStartView];
            }

            if (state.integerValue == LOGIN_STATE_LOADINGVEHICLEPRIVILIGESUCCESS) {
                //登录成功上报一次快捷键
                [[SOSQuickStartHelper sharedInstance] uploadSelectQuickIfFirstLogin];
            }
            

    //#if __has_include("SOSSDK.h")
            if ([[LoginManage sharedInstance] isLoadingUserBasicInfoReady]) {
                [self baseViewLoginState];
            }
    //#endif
            
        });
    }];
    
    [RACObserve([SOSGreetingManager shareInstance], roleGreeting) subscribeNext:^(id x) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([x isKindOfClass:[NSDictionary class]]) {
                [self refreshWithStatus:RemoteControlStatus_OperateSuccess];
            }else if ([x isEqual:@NO]){
                [self refreshWithStatus:RemoteControlStatus_OperateFail];
            }else {
                [self refreshWithStatus:RemoteControlStatus_InitSuccess];
            }
        });
        
    }];
    
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:SOS_VEHICLE_OPERATE_NOTIFICATION object:nil] subscribeNext:^(NSNotification *noti) {
        //        @{@"state":@(RemoteControlStatus_OperateFail), @"OperationType" : @(type)}
        NSDictionary *notiDic = noti.userInfo;
        RemoteControlStatus resultState = [notiDic[@"state"] intValue];
        SOSRemoteOperationType operationType = [notiDic[@"OperationType"] intValue];
        BOOL havc = [notiDic[@"HVAC"] boolValue];
        if (notiDic[@"OperationType"]) {
            if (operationType == SOSRemoteOperationType_RemoteStart && havc) {
                self.operationingType = SOSRemoteOperationType_OpenHVAC;
            }else if(operationType == SOSRemoteOperationType_CloseHVAC) {
                self.operationingType = SOSRemoteOperationType_OpenHVAC;
            }else if (operationType == SOSRemoteOperationType_Light || operationType == SOSRemoteOperationType_Horn) {
                self.operationingType = SOSRemoteOperationType_LightAndHorn;
            }else {
                self.operationingType = operationType;
            }
            self.RemoteControlStatus = resultState;
            [self.quickStartView reloadDataSingle];
        }
    }];
}
- (void)reloadQuickStartView{
    if (self.quickStartView) {
        [[SOSQuickStartHelper sharedInstance] reloadSelectAndAllQS];
           [self.quickStartView reloadData];
    }
}
- (void)refreshWithStatus:(RemoteControlStatus)status {
    
    switch (status) {
        case RemoteControlStatus_OperateSuccess:
        case RemoteControlStatus_OperateFail:
        {
            SOSGreetingModel *model = [[SOSGreetingManager shareInstance] getGreetingModelWithType:SOSGreetingTypeStarTravel];
            // model.greetings;
            if ([SOSCheckRoleUtil isOwner]||[SOSCheckRoleUtil isDriverOrProxy]) {
                greetingLabel.text = model.greetings;
            }else{
                greetingLabel.text = nil;
            }
        }
            break;
            
        case RemoteControlStatus_InitSuccess:
            if ([SOSCheckRoleUtil isOwner]||[SOSCheckRoleUtil isDriverOrProxy]) {
                greetingLabel.text = @"读取中...";
            }else{
                greetingLabel.text = nil;
            }
            break;
        default:
            break;
    }
}

////////////
//未登录
-(void)baseViewUnloginState{
    self.state = SOSVehicleHeaderStateUnlogin;
    if (SOS_APP_DELEGATE.useSkin) {
                self.backgroundImageV.image = [UIImage sossk_imageNamed:@"vehicle_top_bg"];
           }else{
               [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeHomePage avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
                      self.backgroundImageV.image = avatar;
                  }];
           }
   
    [self configAreaPromptUnlogin];
    [self configAreaVeConUnlogin];
}
//登录中
-(void)baseViewInloginState{
    //    [self configAreaPromptUnlogin];
    //    [self configAreaVeCon];
    self.state = SOSVehicleHeaderStateLoading;
    [self.loginButton removeFromSuperview];
    self.loginButton = nil;
}
//登录完成
-(void)baseViewLoginState{
    if (self.state != SOSVehicleHeaderStateLogin) {
        self.state = SOSVehicleHeaderStateLogin;
       
        if (SOS_APP_DELEGATE.useSkin) {
             self.backgroundImageV.image = [UIImage sossk_imageNamed:@"vehicle_top_bg"];
        }else{
            [[SOSAvatarManager sharedInstance] fetchVehicleAvatar:SOSVehicleAvatarTypeHomePage avatarBlock:^(UIImage * _Nullable avatar, BOOL isPlacholder) {
                       self.backgroundImageV.image = avatar;
                   }];
        }
        [self configAreaPromptLoginReady];
        if (![SOSCheckRoleUtil isVisitor]) {
            [self configAreaVeConLoginReady];
        }
    }

}

#pragma mark === FMHorizontalMenuViewDataSource

//-(UINib *)customCollectionViewCellNibForHorizontalMenuView:(SOSHorizontalMenuView *)view{
//    return [UINib nibWithNibName:@"FMCollectionViewCell" bundle:nil];
//}
//-(void)setupCustomCell:(UICollectionViewCell *)cell forIndex:(NSInteger)index horizontalMenuView:(SOSHorizontalMenuView *)view{
//
////        FMCollectionViewCell *myCell = (FMCollectionViewCell*)cell;
////        myCell.kindLabel.text = @"测试";
//
//}
#pragma mark === SOSQucikStartDelegate
- (void)editCompleteWithSelectQS:(NSMutableArray<SOSQSModelProtol> *)selectqsArray andAllqsArray:(NSMutableArray *)allqsArray{
    NSLog(@"select %@",selectqsArray);
    [[SOSQuickStartHelper sharedInstance] saveThirdFuncs:selectqsArray];
    [SOSQuickStartHelper sharedInstance].selectFuncs = selectqsArray;
    [self.quickStartView reloadData];
}
#pragma mark === FMHorizontalMenuViewDelegate
- (NSInteger)numberOfItemsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView section:(NSInteger)section{
    
    return [SOSQuickStartHelper sharedInstance].selectFuncs.count +1;
}

- (NSInteger)numberOfSectionsInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    return 1;
}
-(NSInteger)numOfRowsPerPageInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    return 1;
}

-(NSInteger)numOfColumnsPerPageInHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView{
    return 4;
}

- (void)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView didSelectItemAtIndex:(NSIndexPath *)index{
    
    if (index.row == [SOSQuickStartHelper sharedInstance].selectFuncs.count) {
        SOSQuickStartEditorViewController * con =[[SOSQuickStartEditorViewController alloc] initWithSelectqsArray:[SOSQuickStartHelper sharedInstance].selectFuncs allqsArray:[SOSQuickStartHelper sharedInstance].totalShowFuncs groupNameArray:@[
            @"远程遥控",
            @"定位与出行",
            @"社区",
            @"车况与车辆设置",
            @"车辆服务",
            @"客户服务"] needUniqueCheck:NO];
        con.delegate = self;
        con.navTitle = @"快捷操作";
        con.editNavTitle = @"编辑快捷操作";
        con.backFunctionID = Backtohome;
        con.editFunctionID = Quick_edit;
        con.saveFunctionID = Quick_done;
        [con setCellClickBlock:^(id<SOSQSModelProtol>modelItem) {
            [[SOSQuickStartHelper sharedInstance] invocationActionFromModel:modelItem];
        }];
        [self.viewController.navigationController pushViewController:con animated:YES];
        [SOSDaapManager sendActionInfo:Quickly_More];
    }else{

        [[SOSQuickStartHelper sharedInstance] invocationActionFromModel:[[SOSQuickStartHelper sharedInstance].selectFuncs objectAtIndex:index.row]];
    }
}

- (void)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView congfigItem:(SOSHorizontalMenuViewCell *)cell atIndex:(NSIndexPath *)index {
    if (index.row == [SOSQuickStartHelper sharedInstance].selectFuncs.count ) {
        cell.menuTile.text = @"更多";
        cell.menuIcon.image = [UIImage sosSDK_imageNamed:@"vehicle_operation_car_control_icon_more"];
        return;
    }
    id<SOSQSModelProtol> model = SOSQuickStartHelper.sharedInstance.selectFuncs[index.row];
    NSString *title;
    NSString *img;
    title = model.modelTitle;
    img = SOSQuickStartHelper.sharedInstance.selectFuncs[index.row].modelImage;
    cell.menuTile.text = title;
    cell.menuIcon.image = [UIImage imageNamed:img];
    if (model.remoteOpeType == self.operationingType && self.RemoteControlStatus == RemoteControlStatus_InitSuccess) {
        //refreshing
        [cell shouldLoading:YES];
    }else {
        //normal
        [cell shouldLoading:NO];
    }

}
//
//- (NSString *)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView titleForItemAtIndex:(NSIndexPath *)index{
//    if (index.row == [SOSQuickStartHelper sharedInstance].selectFuncs.count ) {
//        return @"更多";
//    }else{
//        if ([[[SOSQuickStartHelper sharedInstance].selectFuncs objectAtIndex:index.row] respondsToSelector:@selector(modelTitle)]) {
//             return [[[SOSQuickStartHelper sharedInstance].selectFuncs objectAtIndex:index.row] modelTitle];
//        }else{
//            return @"更多";
//        }
//
//    }
//}
//
//- (NSString *)horizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView localIconStringForItemAtIndex:(NSIndexPath *)index{
//    if (index.row ==  [SOSQuickStartHelper sharedInstance].selectFuncs.count ) {
//        return @"vehicle_operation_car_control_icon_more";
//    }else{
//        return [[ [SOSQuickStartHelper sharedInstance].selectFuncs objectAtIndex:index.row] modelImage];
//    }
//
//}
- (CGSize)iconSizeForHorizontalMenuView:(SOSHorizontalMenuView *)horizontalMenuView  index:(NSIndexPath *)index{
    return CGSizeMake(60, 60);
}

-(void)vehicleConditionClicked{
    [SOSCardUtil routerToVehicleCondition];
    [SOSDaapManager sendActionInfo:VEHICLEDIA_PIC_CLICK_ENTRY];
}
-(void)clickLogin{
    if (buttonType == SOSVehicleHeaderButtonTypeLogin) {
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(SOSHomeMeTabProtocol)]) {
            [self.delegate clickLogin];
            [SOSDaapManager sendActionInfo:VEHICLE_LOGIN_];
        }
    }else{
        [SOSCardUtil routerToUpgradeSubscriber];
    }
}
//////////////////////////////////

#pragma mark -- getter
-(UIImageView *)backgroundImageV{
    if (!_backgroundImageV) {
        _backgroundImageV = [[UIImageView alloc] init];
        _backgroundImageV.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundImageV.clipsToBounds = YES;
       
        [totalBaseView insertSubview:_backgroundImageV atIndex:0];
        [_backgroundImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(totalBaseView);
        }];
    }
    return _backgroundImageV;
}
////
/////登录后界面元素
-(void)configAreaPromptLoginReady{
    if ([SOSCheckRoleUtil isVisitor]) {
        [self layoutButtonForType:SOSVehicleHeaderButtonTypeUpgradeSub];
        
    }else{
        [self.areaPrompt removeAllSubviews];
        self.promptLabel=nil;
        self.loginButton=nil;
        NSLog(@"promptLabel:%@",self.promptLabel);
        //        self.areaPrompt.backgroundColor = [UIColor yellowColor];
        SOSGotoVehicleConditionView * gotoVehicleCondition = [[SOSGotoVehicleConditionView alloc] initWithFrame:CGRectZero];
        //        gotoVehicleCondition.backgroundColor = [UIColor greenColor];
        [self.areaPrompt addSubview:gotoVehicleCondition];
        [gotoVehicleCondition mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.areaPrompt);
            make.top.mas_equalTo(self.areaPrompt);
            make.width.mas_equalTo(self.areaPrompt.mas_width);
            make.height.mas_equalTo(22);
        }];
        
        SOSVehicleLocationStatusView * gotoVehicleLocation = [[SOSVehicleLocationStatusView alloc] initWithFrame:CGRectZero];
        [self.areaPrompt addSubview:gotoVehicleLocation];
        //        gotoVehicleLocation.backgroundColor = [UIColor grayColor];
        [gotoVehicleLocation mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(gotoVehicleCondition);
            make.top.mas_equalTo(gotoVehicleCondition.mas_bottom).mas_offset(18.0f);
            make.width.mas_equalTo(self.areaPrompt.mas_width);
            make.height.mas_equalTo(36);
        }];
    }
    
}
-(void)configAreaVeConLoginReady{
    
    //混动车
    if ([Util vehicleIsPHEV]) {
        if (sexangleProgress && sexangleProgress.superview) {
            [sexangleProgress removeFromSuperview];
            sexangleProgress = nil;
        }
        if (!phevBackgroundImage) {
            phevBackgroundImage = [[UIImageView alloc] initWithImage:[UIImage sossk_imageNamed:@"vehicle_ev_hexagon_bg"]];
            [self.areaVeCon insertSubview:phevBackgroundImage atIndex:0];
            [phevBackgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.areaVeCon);
            }];
        }
        [self.enduranceLabel setText:@"预估综合续航"];
        [self refreshVehicleChargeStateForEVPHEV];
    }else{
        //纯电动
        if ([Util vehicleIsEV]) {
            [self refreshVehicleChargeStateForEVPHEV];
        }else{
            //燃油
            [self refreshVehicleFlueStateForFV];
        }
    }
}
-(void)refreshVehicleFlueStateForFV{
    [self.enduranceLabel setText:@"燃油余量"];
    if (!chargeStateImage) {
        chargeStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicle_icon_fluestation"]];
        [_areaVeCon addSubview:chargeStateImage];
        [chargeStateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_areaVeCon);
            make.bottom.mas_equalTo(_enduranceLabel.mas_top).mas_offset(-8.0f);
        }];
    }
    self.kmLabel.hidden = YES;
    self.meterLabel.hidden = YES;
    
    [RACObserve([CustomerInfo sharedInstance] , fuelLavel) subscribeNext:^(NSString *range) {
        if (range) {
            [self refreshFVProgress:range];
            self.sta = SOSVehicleConditonNormal;
           
        }
    }];
    //test
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [CustomerInfo sharedInstance].vehicleRange = @"0.5";
    //        });
}
-(void)refreshFVProgress:(NSString *)progressStr{
    CGFloat percent = progressStr.floatValue/100.0f;
    if (SOS_APP_DELEGATE.useSkin) {
        [sexangleProgress refreshProgess:percent appointProgressColor:[UIColor whiteColor]];
    }else{
        if (percent<= 0.1f) {
            [sexangleProgress refreshProgess:percent appointProgressColor:[UIColor colorWithHexString:@"FF4949"]];
        }else{
            if (percent>0.1f && percent<=0.2f) {
                [sexangleProgress refreshProgess:percent appointProgressColor:[UIColor colorWithHexString:@"F18F19"]];
            }else{
                [sexangleProgress refreshProgess:percent appointProgressColor:nil];
            }
        }
    }
    
}
//刷新EV/PHEV充电状态
-(void)refreshVehicleChargeStateForEVPHEV{
    [RACObserve([CustomerInfo sharedInstance],chargeState) subscribeNext:^(NSString *chs) {
        if (chs) {
            dispatch_sync_on_main_queue(^{
                if ([chs isEqualToString:SOSVehicleChargeStateCharging]) {
                    //1
                    [self showChargeStateViewWithState:1];
                    
                }else if ([chs isEqualToString:SOSVehicleChargeStateNotCharging]) {
                    
                    [self hideChargeStateViewIfNeeded];
                    
                }else if ([chs isEqualToString:SOSVehicleChargeStateChargingComplete]) {
                    //2
                    [self showChargeStateViewWithState:2];
                }
            });
            
        }
    }];
    if ([Util vehicleIsEV]) {
        [RACObserve([CustomerInfo sharedInstance],bevBatteryStatus) subscribeNext:^(NSString *bevBatterySta) {
            dispatch_sync_on_main_queue(^{
                if([Util isValidNumber:bevBatterySta]){
                    [self refreshFVProgress:bevBatterySta];
                }else{
                    [self refreshFVProgress:0];
                }
            });
        }];
        [RACObserve([CustomerInfo sharedInstance],bevBatteryRange) subscribeNext:^(NSString *bevBatteryRange) {
            dispatch_sync_on_main_queue(^{
                if(![Util isValidNumber:bevBatteryRange]){
                    [self.meterLabel setText:@"--"];
                }else{
                    [self.meterLabel setText:bevBatteryRange];
                }
            });
            
        }];
        
    }else{
        [RACObserve([CustomerInfo sharedInstance],evTotleRange) subscribeNext:^(NSString *evTotleRange) {
            dispatch_sync_on_main_queue(^{
                if(![Util isValidNumber:evTotleRange]){
                    [self.meterLabel setText:@"--"];
                } else {
                    [self.meterLabel setText:evTotleRange];
                }
            });
            
        }];
    }
    //    //test
    //    [self showChargeStateViewWithState:1];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self showChargeStateViewWithState:2];
    //    });
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [CustomerInfo sharedInstance].evRange = @"10000";
    //        [CustomerInfo sharedInstance].chargeState = @"charging";
    //    });
}
-(void)showChargeStateViewWithState:(NSInteger)state{
    switch (state) {
        case 1:
            [self startChargeAnimiation];
            break;
        case 2:
            [self stopChargeAnimiation];
            break;
            
        default:
            break;
    }
}
-(void)hideChargeStateViewIfNeeded{
    if (chargeStateImage) {
        [chargeStateImage removeFromSuperview];
        chargeStateImage = nil;
    }
    if ([Util vehicleIsEV]) {
        [self.enduranceLabel setText:@"预估续航"];
    }else{
        [self.enduranceLabel setText:@"预估综合续航"];
    }
    self.kmLabel.hidden = NO;
    self.meterLabel.hidden = NO;
    self.sta = SOSVehicleConditonNormal;
}
-(void)startChargeAnimiation{
    if (!chargeStateImage) {
        chargeStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicle_icon_incharge"]];
        [_areaVeCon addSubview:chargeStateImage];
        [chargeStateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_areaVeCon);
            make.bottom.mas_equalTo(_enduranceLabel.mas_top).mas_offset(-8.0f);
        }];
    }
    [self.enduranceLabel setText:@"充电中"];
    self.kmLabel.hidden = YES;
    self.meterLabel.hidden = YES;
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.duration = 3.0f;
    opacityAnimation.autoreverses= YES;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.repeatCount = MAXFLOAT;
    [chargeStateImage.layer addAnimation:opacityAnimation forKey:nil];
    self.sta = SOSVehicleConditonInCharge;
    if ([Util vehicleIsEV]) {
        [sexangleProgress startCircleAnimation];
    }
    //test
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self stopChargeAnimiation];
    //    });
}
-(void)stopChargeAnimiation{
    if (!chargeStateImage) {
        chargeStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicle_icon_incharge"]];
        [_areaVeCon addSubview:chargeStateImage];
        [chargeStateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_areaVeCon);
            make.bottom.mas_equalTo(_enduranceLabel.mas_top).mas_offset(-8.0f);
        }];
    }
    [chargeStateImage.layer removeAllAnimations];
    [self.enduranceLabel setText:@"已充满"];
    self.kmLabel.hidden = YES;
    self.meterLabel.hidden = YES;
    if ([Util vehicleIsEV]) {
        [sexangleProgress refreshProgess:1.0f appointProgressColor:nil];
    }
    self.sta = SOSVehicleConditonChargeComplete;
}
-(void)hideChargeModeView{
    if (chargeStateImage) {
        [chargeStateImage removeFromSuperview];
        chargeStateImage = nil;
    }
}
////////////////////////////////
-(void)configAreaVeConUnlogin{
    if (!sexangleProgress) {
        sexangleProgress = [[SOSSexangleView alloc] initWithFrame:CGRectZero];

    }
    if (phevBackgroundImage) {
        [phevBackgroundImage removeFromSuperview];
        phevBackgroundImage = nil;
    }
    [self.areaVeCon addSubview:sexangleProgress];
    [sexangleProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.areaVeCon);
    }];
    if (chargeStateImage) {
        [chargeStateImage removeFromSuperview];
        chargeStateImage = nil;
    }
    [sexangleProgress drawSexangleWithImageViewWidth:areaVeConWidth withLineWidth:6.0f withBackgroundStrokeColor:[UIColor sos_skinColorWithKey:@"themeColorPack.vehicleProgressBean.vehicleProgressFirstColor"] progressStrokeColor:[UIColor sos_skinColorWithKey:@"themeColorPack.vehicleProgressBean.vehicleProgressSecondColor"]];
    
    self.sta = SOSVehicleConditonUnknown;
    [self initVehicleStatusAttr];
}
-(void)initVehicleStatusAttr{
    if (self.meterLabel.hidden) {
        self.meterLabel.hidden = NO;
    }else{
        [self.meterLabel setText:@"--"];
        [self.meterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.areaVeCon);
            make.centerY.mas_equalTo(self.areaVeCon).mas_offset(-10);
        }];
        [self.kmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.meterLabel.mas_top);
            make.left.mas_equalTo(self.meterLabel.mas_right);
        }];
    }
    
    if (self.enduranceLabel.hidden) {
        self.enduranceLabel.hidden = NO;
    }else{
        [self.enduranceLabel setText:@"预估续航"];
        [self.enduranceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.areaVeCon);
            make.top.mas_equalTo(self.meterLabel.mas_bottom);
        }];
    }
    if (self.kmLabel.hidden) {
        self.kmLabel.hidden = NO;
    }
}
-(void)configAreaPromptUnlogin{
    [self.areaPrompt removeAllSubviews];
    [self.areaPrompt addSubview:self.promptLabel];
    self.promptLabel.text=@"欢迎使用安吉星";
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_areaPrompt);
        make.top.mas_equalTo(_areaPrompt);
    }];
    [self layoutButtonForType:SOSVehicleHeaderButtonTypeLogin];
    
}
-(void)layoutButtonForType:(NSInteger)buttonType_{
    
    [self.areaPrompt addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_areaPrompt);
        make.top.mas_equalTo(self.promptLabel.mas_bottom).mas_offset(12.0f);
        make.width.mas_equalTo(84.0f);
    }];
    if (buttonType_ == SOSVehicleHeaderButtonTypeLogin) {
        [self.loginButton setTitle:@"立即登录" forState:UIControlStateNormal];
    }else{
        [self.loginButton setTitle:@"升级为车主" forState:UIControlStateNormal];
    }
    buttonType = buttonType_;
}
/////////////
- (UIView *)areaPrompt
{
    if (_areaPrompt == nil) {
        _areaPrompt = [[UIView alloc] init];
        [totalBaseView addSubview:_areaPrompt];
        //        _areaPrompt.backgroundColor = [UIColor blueColor];
        [_areaPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(totalBaseView).mas_offset(12.0f);
            make.centerY.mas_equalTo(totalBaseView).mas_offset(50.0f);
            make.width.mas_equalTo(totalBaseView).multipliedBy(0.496);
            make.height.mas_equalTo(80);
        }];
        
    }
    return _areaPrompt;
}
- (UIView *)areaVeCon
{
    if (_areaVeCon == nil) {
        _areaVeCon = [[UIView alloc] init];
        [_areaVeCon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vehicleConditionClicked)]];
        
        [totalBaseView addSubview:_areaVeCon];
        CGFloat lead = SCALE_WIDTH(20.0f);
        [_areaVeCon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(areaVeConWidth);
            make.height.mas_equalTo(areaVeConWidth);
            make.trailing.mas_equalTo(totalBaseView).mas_offset(-lead);
            make.centerY.mas_equalTo(totalBaseView);
        }];
        if (_kmLabel == nil) {
            _kmLabel = [[UILabel alloc] init];
            _kmLabel.textColor = [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.vehicleHexagonFontColor"];
            _kmLabel.text = @"km";
            _kmLabel.font = [UIFont fontWithName:@"DIN Alternate" size: 18];
            [self.areaVeCon addSubview:_kmLabel];
        }
        
    }
    return _areaVeCon;
}
- (UILabel *)promptLabel
{
    if (_promptLabel == nil) {
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.textColor = [UIColor colorWithHexString:@"#4E5059"];
        _promptLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 15];
    }
    return _promptLabel;
}
- (UILabel *)meterLabel
{
    if (_meterLabel == nil) {
        _meterLabel = [[UILabel alloc] init];
        _meterLabel.textColor = [UIColor whiteColor];
        _meterLabel.font = [UIFont fontWithName:@"DINAlternate-Bold" size: 52];
        [self.areaVeCon addSubview:_meterLabel];
    }
    return _meterLabel;
}
- (UILabel *)enduranceLabel
{
    
    if (_enduranceLabel == nil) {
        _enduranceLabel = [[UILabel alloc] init];
        _enduranceLabel.textColor = [UIColor sos_skinColorWithKey:@"themeColorPack.themeColorBean.vehicleHexagonFontColor"];
        _enduranceLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        [self.areaVeCon addSubview:_enduranceLabel];
    }
    return _enduranceLabel;
}

- (UIButton *)loginButton
{
    if (_loginButton == nil) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _loginButton.layer.borderWidth = 1.0f;
        _loginButton.layer.cornerRadius = 2.0f;
        _loginButton.layer.borderColor = [UIColor colorWithHexString:@"#6896ED"].CGColor;
        [_loginButton setTitleColor:[UIColor colorWithHexString:@"#6896ED"] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_loginButton addTarget:self action:@selector(clickLogin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}
-(void)setSta:(SOSVehicleConditonStatus)sta{
    _sta = sta;
    if ([self.delegate respondsToSelector:@selector(refreshWithHeaderViewStatus)]) {
        [self.delegate performSelector:@selector(refreshWithHeaderViewStatus)];
    }
}

@end
