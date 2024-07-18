//
//  SOSHVACSettingVC.m
//  Onstar
//
//  Created by Coir on 2018/4/19.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSRemoteTool.h"
#import "SOSHVACSettingVC.h"
#import "SOSFanSliderView.h"

NSString * const KUserdefaultHVACSettingKey = @"KUserdefaultHVACSettingKey";

@interface SOSHVACSettingModel: NSObject

/// Drive 侧温度	(接口允许14 - 31.5)	(需求设计 16 - 32)
@property (strong, nonatomic) NSNumber *hvacDriverTemperature;
/// 同步 Passenger 侧温度 BOOL	固定传值 YES
@property (strong, nonatomic) NSNumber *hvacSyncPassengerTemperature;
/// Passenger 侧温度	(接口允许14 - 31.5)    (需求设计 16 - 32)
@property (strong, nonatomic) NSNumber *hvacPassengerTemperature;
/// 空调 Drive 侧出风口设置
@property (copy, nonatomic) NSString *hvacDriverAirDist;
///// 空调 Passenger 侧出风口设置 (本期不传值)
//@property (strong, nonatomic) NSString *hvacPassengerAirDist;
/// 自动模式 BOOL
@property (strong, nonatomic) NSNumber *hvacSetAutoClimate;
/// 风速 (接口允许 0 - 18 )	(需求设计 0 - 15)  !!! 为 0 时风扇关闭,空调关闭
@property (strong, nonatomic) NSNumber *hvacFanSpeed;
/// 压缩机模式	固定传值 AC_NORM_ACTIVE
@property (copy, nonatomic) NSString *hvacAcClimateMode;
/// 车内循环	BOOL
@property (strong, nonatomic) NSNumber *hvacRecirculateAir;
/// 后窗除雾	BOOL
@property (strong, nonatomic) NSNumber *hvacRearDefogOn;


@property (nonatomic, strong) NSNumber *isOpen;

@end

@implementation SOSHVACSettingModel


+ (SOSHVACSettingModel *)buildDefaultModel	{
    SOSHVACSettingModel *settingModel = [SOSHVACSettingModel new];
    settingModel.isOpen = @(YES);
    settingModel.hvacAcClimateMode = @"AC_NORM_ACTIVE";
    settingModel.hvacRecirculateAir = @(NO);
    settingModel.hvacSetAutoClimate = @(YES);
    settingModel.hvacSyncPassengerTemperature = @(YES);
    settingModel.hvacDriverTemperature = @(26);
    settingModel.hvacPassengerTemperature = @(26);
    settingModel.hvacRearDefogOn = @(NO);
    settingModel.hvacFanSpeed = @(1);
    
    return settingModel;
}

- (void)saveCurrentSetting    {
    NSString *vin = [CustomerInfo sharedInstance].currentVehicle.vin;
    if (!vin.length)    return;
    
    NSDictionary *keyValuesDic = self.mj_keyValues;
    if (keyValuesDic.count) {
        NSString *md5VinStr = vin.md5String;
        NSMutableDictionary *originDic = [NSMutableDictionary dictionaryWithDictionary:UserDefaults_Get_Object(KUserdefaultHVACSettingKey)];
        originDic[md5VinStr] = keyValuesDic;
        UserDefaults_Set_Object(originDic, KUserdefaultHVACSettingKey);
    }
}

+ (SOSHVACSettingModel *)readSavedSetting	{
    NSString *vin = [CustomerInfo sharedInstance].currentVehicle.vin;
    if (!vin.length)    return [SOSHVACSettingModel buildDefaultModel];
    
    NSDictionary *allSavedValues = UserDefaults_Get_Object(KUserdefaultHVACSettingKey);
    if (allSavedValues.count) {
        NSString *md5VinStr = vin.md5String;
        NSDictionary *dic = allSavedValues[md5VinStr];
        if (dic.count) {
            SOSHVACSettingModel *settingModel = [SOSHVACSettingModel mj_objectWithKeyValues:dic];
            if (settingModel)	return settingModel;
        }
    }
    SOSHVACSettingModel *settingModel = [SOSHVACSettingModel buildDefaultModel];
    return settingModel;
}

@end


@interface SOSHVACSettingVC () <SOSFanSliderDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *hvacSwitch;

@property (weak, nonatomic) IBOutlet UIView *fanBGView;
@property (weak, nonatomic) IBOutlet SOSFanSliderView *fanSliderView;
@property (weak, nonatomic) IBOutlet UIButton *fanDownButton;
@property (weak, nonatomic) IBOutlet UIButton *fanUpButton;

/// 自动
@property (weak, nonatomic) IBOutlet UIButton *autoButton;
/// 前窗除霜
@property (weak, nonatomic) IBOutlet UIButton *frontWindowDefrostButton;
/// 后窗除雾
@property (weak, nonatomic) IBOutlet UIButton *rearWindowDefogButton;
/// 内/外 循环
@property (weak, nonatomic) IBOutlet UIButton *loopButton;
/// 吹头
@property (weak, nonatomic) IBOutlet UIButton *headButton;
/// 吹脚
@property (weak, nonatomic) IBOutlet UIButton *footButton;
/// 吹前窗 & 脚
@property (weak, nonatomic) IBOutlet UIButton *frontWindowAndFootButton;
/// 吹头 & 脚
@property (weak, nonatomic) IBOutlet UIButton *headAndFootButton;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;

@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *hvavSettingButtonBGView;

@property (weak, nonatomic) IBOutlet UILabel *temperatureFlagLabel;

@property (strong, nonatomic) SOSHVACSettingModel *settingModel;

@property (assign, nonatomic) ushort temperature;

@end

@implementation SOSHVACSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fanSliderView.delegate = self;
    self.settingModel = [SOSHVACSettingModel readSavedSetting];
    [self recoverViewFromSettingModel:self.settingModel];
}

- (void)viewWillDisappear:(BOOL)animated	{
    [super viewWillDisappear:animated];
    [self configSettingModelWithCurrentStatus];
    [self.settingModel saveCurrentSetting];
}

#pragma mark - 设置 View 状态
- (void)setTemperatureLabelWithTemperature:(int)temperature        {
    int tem = temperature;
    if (tem >= 32)        {
        tem = 32;
        self.temperature = tem;
        self.upButton.enabled = NO;
        self.temperatureLabel.text = @"HI";
//        self.temperatureFlagLabel.hidden = YES;//defect 21240
    }    else if (tem <= 16)    {
        tem = 16;
        self.temperature = tem;
        self.downButton.enabled = NO;
        self.temperatureLabel.text = @"LO";
//        self.temperatureFlagLabel.hidden = YES;
    }    else    {
        if (!self.upButton.isEnabled)                 self.upButton.enabled = YES;
        if (!self.downButton.isEnabled)                self.downButton.enabled = YES;
        if (self.temperatureFlagLabel.isHidden)     self.temperatureFlagLabel.hidden = NO;
        self.temperatureLabel.text = [NSString stringWithFormat:@"%d", tem];
    }
}

- (void)setTemperatureViewEnable:(BOOL)enable    {
    self.upButton.enabled = enable;
    self.downButton.enabled = enable;
    if (enable)     {
//        self.temperatureLabel.textColor = [UIColor colorWithHexString:@"107FE0"];
        [self setTemperatureLabelWithTemperature:self.temperature];
    }	else		{
//        self.temperatureLabel.textColor = [UIColor colorWithHexString:@"C7CFD8"];
        self.temperatureLabel.text = @"--";
    }
}

- (void)setFanViewEnable:(BOOL)enable    {
    self.fanDownButton.selected = !enable;
    self.fanUpButton.selected = !enable;
    if (enable) {
        if (self.settingModel.hvacFanSpeed.intValue)	self.fanSliderView.fanValue = self.settingModel.hvacFanSpeed.intValue;
        else											self.fanSliderView.fanValue = 1;
    }	else											self.fanSliderView.fanValue = 0;
}

#pragma mark - 恢复状态
- (void)recoverViewFromSettingModel:(SOSHVACSettingModel *)settingModel		{
    if (!settingModel)	settingModel = [SOSHVACSettingModel buildDefaultModel];
    self.hvacSwitch.on = settingModel.isOpen.boolValue;
    if (settingModel.isOpen.boolValue) {
        // 恢复后窗除雾
        if (settingModel.hvacRearDefogOn.boolValue)	 	[self hvacSettingButtonTapped:self.rearWindowDefogButton];
        
        // 空调温度显示 向上取整
        self.temperature = ceil( self.settingModel.hvacDriverTemperature.floatValue );
        [self setTemperatureLabelWithTemperature:self.temperature];
        
        // 自动模式
        if (settingModel.hvacSetAutoClimate.boolValue) {
            self.autoButton.selected = NO;
            [self hvacSettingButtonTapped:self.autoButton];
        }	else	{
            // 清空除 后窗除雾 外其他 Button 选中状态
            for (UIView *view in self.hvavSettingButtonBGView.subviews) {
                if ([view isKindOfClass:[UIButton class]] && (view != _rearWindowDefogButton))    {
                    ((UIButton *)view).selected = NO;
                }
            }
            
            // 恢复 自动模式 状态
            if (self.settingModel.hvacRecirculateAir.boolValue) 	[self hvacSettingButtonTapped:self.loopButton];
            
            // 恢复风速设置
            self.fanSliderView.fanValue = settingModel.hvacFanSpeed.intValue;
            // 恢复 出风口设置
            NSString *hvacAirDist = settingModel.hvacDriverAirDist;
            UIButton *tempButton = nil;
            //      - COMBI_DEFROST 除霜
            if ([hvacAirDist isEqualToString:@"COMBI_DEFROST"]) 		tempButton = _frontWindowDefrostButton;
            //    - COMBI_WIND_FLR 吹挡风玻璃+脚
            else if ([hvacAirDist isEqualToString:@"COMBI_WIND_FLR"]) 	tempButton = _frontWindowAndFootButton;
            //    - COMBI_WIND 吹挡风玻璃
            else if ([hvacAirDist isEqualToString:@"COMBI_WIND"]) 		tempButton = _frontWindowAndFootButton;
            //    - COMBI_PNL 吹脸
            else if ([hvacAirDist isEqualToString:@"COMBI_PNL"]) 		tempButton = _headButton;
            //    - COMBI_FLR 吹脚
            else if ([hvacAirDist isEqualToString:@"COMBI_FLR"])		tempButton = _footButton;
            //    - COMBI_FLR_PNL 吹脚+脸
            else if ([hvacAirDist isEqualToString:@"COMBI_FLR_PNL"]) 	tempButton = _headAndFootButton;
            
            [self hvacSettingButtonTapped:tempButton];
        }
    }	else	{
        // 清空按键选中状态
        for (UIView *view in self.hvavSettingButtonBGView.subviews) {
            if ([view isKindOfClass:[UIButton class]])    {
                ((UIButton *)view).selected = NO;
            }
        }
        [self setFanViewEnable:NO];
        [self setTemperatureViewEnable:NO];
        self.fanBGView.userInteractionEnabled = NO;
        self.hvavSettingButtonBGView.userInteractionEnabled = NO;
    }
}

#pragma mark - 取消
- (IBAction)cancelButtonTapped 	{
    [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_BACK];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 空调开关
- (IBAction)hvacSwitchTapped:(UISwitch *)sender {
    NSString *recordStr = @"";
    if (sender.isOn) {
    	// 打开空调
        self.switchLabel.text = @"空调开启";
        recordStr = REMOTECONTROL_HVACSETTINGS_ON;
        self.settingModel = [SOSHVACSettingModel readSavedSetting];
        self.settingModel.isOpen = @(YES);
        [self recoverViewFromSettingModel:self.settingModel];
    }	else	{
        // 关闭空调, 保存当前状态
        self.switchLabel.text = @"空调关闭";
        recordStr = REMOTECONTROL_HVACSETTINGS_OFF;
        [self configSettingModelWithCurrentStatus];
        [self.settingModel saveCurrentSetting];
        // 清空按键选中状态
        for (UIView *view in self.hvavSettingButtonBGView.subviews) {
            if ([view isKindOfClass:[UIButton class]])    {
                ((UIButton *)view).selected = NO;
            }
        }
    }
    [self setFanViewEnable:sender.isOn];
    [self setTemperatureViewEnable:sender.isOn];
    self.fanBGView.userInteractionEnabled = sender.isOn;
    self.hvavSettingButtonBGView.userInteractionEnabled = sender.isOn;
    
    [SOSDaapManager sendActionInfo:recordStr];
}

#pragma mark -  调节风速
- (IBAction)fanbuttonTapped:(UIButton *)sender {
    // 点击风速调节,取消 Auto 模式
    self.autoButton.selected = NO;
    if (sender.isSelected == YES) 		[self setFanViewEnable:YES];
    
    // 减小风速
    if (sender.tag == 1001) {
        if (self.settingModel.hvacFanSpeed.intValue <= 1)		return;
        self.settingModel.hvacFanSpeed = @(self.settingModel.hvacFanSpeed.intValue - 1);
        [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_SPEEDLOW];
    }	else if (sender.tag == 1002)	{
        //加大风速
        if (self.settingModel.hvacFanSpeed.intValue >= 6)        return;
        self.settingModel.hvacFanSpeed = @(self.settingModel.hvacFanSpeed.intValue + 1);
        [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_SPEEDHIGH];
    }
    self.fanSliderView.fanValue = self.settingModel.hvacFanSpeed.intValue;
}

/// FanSliderView Delegate
- (void)fanValueChangedWithValue:(int)fanValue	{
//    self.settingModel.hvacFanSpeed = @(fanValue);
}

///调节风速
//- (IBAction)fanSliderChanged:(UISlider *)sender {
//    self.settingModel.HVACFanSpeed = @(sender.value).stringValue;
//}

#pragma mark -  调节 出风口 设置
- (IBAction)hvacSettingButtonTapped:(UIButton *)sender {
    NSString *recordStr = @"";
    sender.selected = !sender.isSelected;
    if (sender == self.autoButton) {
        recordStr = REMOTECONTROL_HVACSETTINGS_AUTO;
        /// 自动 Auto 亮起状态,点击无效
        if (sender.isSelected) {
            // 改为自动, 点击 Auto ,关闭其他状态
            for (UIView *view in self.hvavSettingButtonBGView.subviews) {
                if ([view isKindOfClass:[UIButton class]] && view != self.autoButton
                     && view != self.rearWindowDefogButton)    {
                    ((UIButton *)view).selected = NO;
                }
            }
            // Aoto 与 风速调节 互斥
            [self setFanViewEnable:NO];
        }	else	{
            sender.selected = !sender.isSelected;
        }
        
        if (recordStr.length)	 [SOSDaapManager sendActionInfo:recordStr];
        return;
    }    else if (sender == self.rearWindowDefogButton)        {
      	// 后窗除雾,独立逻辑,只与 开关 状态有关
        recordStr = REMOTECONTROL_HVACSETTINGS_REARDEFOG;
        if (recordStr.length)     [SOSDaapManager sendActionInfo:recordStr];
        return;
    }    else	{
        // 点击其他任何键,取消 Auto 模式
        if (self.autoButton.isSelected) {
            self.autoButton.selected = NO;
            [self setFanViewEnable:YES];
        }
    }
    // 内/外 循环, 只与 Auto 互斥
    if (sender == self.loopButton)        {
        recordStr = REMOTECONTROL_HVACSETTINGS_AIRINLET;
        if (sender.isSelected) 		self.autoButton.selected = NO;
    }	else	{
    // 前窗除霜,吹前窗&脚,吹头,吹脚,吹头&脚 只能保留一个
        NSArray *airDistButtonArray = @[_frontWindowDefrostButton, _headButton, _footButton, _headAndFootButton, _frontWindowAndFootButton];
        [airDistButtonArray enumerateObjectsUsingBlock:^(UIButton *temButton, NSUInteger idx, BOOL * _Nonnull stop) {
            if (temButton != sender && temButton.isSelected)	temButton.selected = NO;
        }];
        if (sender == self.frontWindowDefrostButton) {
            recordStr = REMOTECONTROL_HVACSETTINGS_MAXFROEST;
        }	else if (sender == self.headButton) {
            recordStr = REMOTECONTROL_HVACSETTINGS_VENT;
        }    else if (sender == self.footButton) {
            recordStr = REMOTECONTROL_HVACSETTINGS_FLOOR;
        }    else if (sender == self.headAndFootButton) {
            recordStr = REMOTECONTROL_HVACSETTINGS_BI_LEVEL;
        }    else if (sender == self.frontWindowAndFootButton) {
            recordStr = REMOTECONTROL_HVACSETTINGS_FLOORWINDSHIELD;
        }
    }
    if (recordStr.length)     [SOSDaapManager sendActionInfo:recordStr];
}

#pragma mark -  调节温度
- (IBAction)temperatureButtonTapped:(UIButton *)sender {
    if (sender == self.upButton) {
        //不能超过 32℃
        if (self.temperature == 32)		return;
        else if (self.temperature > 32)		self.temperature = 32;
        self.temperature = self.temperature + 1;
        [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_TEMPERATUREHIGH];
    }	else	{
        //不能小于 16℃
        if (self.temperature == 16)    return;
        else if (self.temperature < 16)		self.temperature = 16;
        self.temperature = self.temperature - 1;
        [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_TEMPERATURELOW];
    }
    [self setTemperatureLabelWithTemperature:self.temperature];
}

#pragma mark -  将当前页面状态映射到 settingModel
- (void)configSettingModelWithCurrentStatus		{
    self.settingModel.isOpen = @(self.hvacSwitch.isOn);
    if (self.hvacSwitch.isOn == NO)		return;
    self.settingModel.hvacDriverTemperature = self.temperature == 32 ? @(31.5) : @(self.temperature);
    self.settingModel.hvacPassengerTemperature = self.settingModel.hvacDriverTemperature;
    
    self.settingModel.hvacRearDefogOn = @(self.rearWindowDefogButton.isSelected);
    //自动模式
    self.settingModel.hvacSetAutoClimate = @(self.autoButton.isSelected);
    if (self.autoButton.isSelected == NO) 	{
        // 内外循环
        self.settingModel.hvacRecirculateAir = @(self.loopButton.isSelected);
        
        NSString *airDistStr  = nil;
        //      - COMBI_DEFROST 除霜
        if (self.frontWindowDefrostButton.isSelected)		airDistStr = @"COMBI_DEFROST";
        //    - COMBI_WIND_FLR 吹挡风玻璃+脚
        else if (self.frontWindowAndFootButton.isSelected) 	airDistStr = @"COMBI_WIND_FLR";
        //    - COMBI_PNL 吹脸
        else if (self.headButton.isSelected)				airDistStr = @"COMBI_PNL";
        //    - COMBI_FLR 吹脚
        else if (self.footButton.isSelected)            	airDistStr = @"COMBI_FLR";
        //    - COMBI_FLR_PNL 吹脚+脸
        else if (self.headAndFootButton.isSelected)        	airDistStr = @"COMBI_FLR_PNL";
        
        self.settingModel.hvacDriverAirDist = airDistStr;
    }
}

#pragma mark -  构造空调请求参数
- (NSString *)buildFinalJsonString	{
    [self configSettingModelWithCurrentStatus];
    NSString *finalStr = nil;
    if (self.hvacSwitch.isOn == NO)		{
//        finalStr = @{@"hvacSettings": @{ @"hvacSetAutoClimate": @(NO), @"hvacAcClimateMode": @"AC_NORM_INACTIVE"}}.mj_JSONString;
        return finalStr;
    }	else	{
        //空调开启
        NSMutableDictionary *keyValues = [self.settingModel mj_keyValues];
        [keyValues removeObjectForKey:@"isOpen"];
        //自动模式下,去除 风速/出风口模式/循环模式 参数
        if (self.autoButton.isSelected)		[keyValues removeObjectsForKeys:@[@"hvacFanSpeed", @"hvacRecirculateAir", @"hvacDriverAirDist"]];
        finalStr = @{@"hvacSettings": keyValues}.mj_JSONString;
        return finalStr;
    }
}

#pragma mark -  发送到车
- (IBAction)sendToCarButtonTapped:(UIButton *)sender 	{
    [SOSDaapManager sendActionInfo:REMOTECONTROL_HVACSETTINGS_SEND];
    NSString *parameters = [self buildFinalJsonString];
    SOSRemoteOperationType operationType = self.hvacSwitch.isOn ? SOSRemoteOperationType_OpenHVAC : SOSRemoteOperationType_CloseHVAC;
    
    [self dismissViewControllerAnimated:NO completion:^{
        [[SOSRemoteTool sharedInstance] startOperationWithOperationType:operationType WithParameters:parameters];
    }];
}

@end
