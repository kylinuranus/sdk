//
//  SOSICMVehicleStatusView.m
//  Onstar
//
//  Created by Coir on 2018/4/25.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSICMVehicleStatusView.h"
#import "SOSVehicleInfoUtil.h"
#import "SOSGreetingManager.h"
#import "ServiceController.h"
#import "SOSDateFormatter.h"

@interface SOSICMVehicleStatusView ()

/// 刷新失败 Image View
@property (weak, nonatomic) IBOutlet UIImageView *refreshFailedImageView;
/// 刷新 Button
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
/// 更新时间 Label
@property (weak, nonatomic) IBOutlet UILabel *updateTimeLabel;
/// 上一条控车指令 Label
@property (weak, nonatomic) IBOutlet UILabel *lastCarDoorCommendsLabel;
/// 车门状态 Label
@property (weak, nonatomic) IBOutlet UILabel *carDoorStatusLabel;
/// 发动机机状态 Label
@property (weak, nonatomic) IBOutlet UILabel *engineStatusLabel;
/// 天窗状态 Label
@property (weak, nonatomic) IBOutlet UILabel *topRoofStatusLabel;
/// 车窗状态 Label
@property (weak, nonatomic) IBOutlet UILabel *sideRoofStatusLabel;
/// 后备箱状态 Label
@property (weak, nonatomic) IBOutlet UILabel *trunkStatusLabel;
/// 车灯状态 Label
@property (weak, nonatomic) IBOutlet UILabel *lightStatusLabel;
/// 双闪灯状态 Label
@property (weak, nonatomic) IBOutlet UILabel *doubelFlashStatusLabel;

@property (weak, nonatomic) IBOutlet UIView *lineView1;
@property (weak, nonatomic) IBOutlet UIView *lineView2;
//天窗异常图标
@property (weak, nonatomic) IBOutlet UIImageView *icon_topRoofUnNormal;
//车窗异常图标
@property (weak, nonatomic) IBOutlet UIImageView *icon_sideRoofUnNormal;


@end

@implementation SOSICMVehicleStatusView


- (void)awakeFromNib	{
    [super awakeFromNib];
    SOSVehicle *info = [CustomerInfo sharedInstance].currentVehicle;
    if (info.lastDoorCommandSupport == NO)		self.lastCarDoorCommendsLabel.hidden = YES;
    if (info.doorPositionSupport == NO)        	self.carDoorStatusLabel.hidden = YES;
    if (info.windowPositionSupport == NO)     	self.sideRoofStatusLabel.hidden = YES;
    if (info.sunroofPositionSupport == NO)    	self.topRoofStatusLabel.hidden = YES;
    if (info.engineStateSupport == NO)        	self.engineStatusLabel.hidden = YES;
    if (info.lightStateSupport == NO)        	self.lightStatusLabel.hidden = YES;
    if (info.trunkPositionSupport == NO)        self.trunkStatusLabel.hidden = YES;
    if (info.flashStateSupport == NO)        	self.doubelFlashStatusLabel.hidden = YES;
    self.icon_topRoofUnNormal.hidden = YES;
    self.icon_sideRoofUnNormal.hidden = YES;
    
    if ([CustomerInfo sharedInstance].icmVehicleRefreshState == RemoteControlStatus_InitSuccess && [ServiceController sharedInstance].switcherLock) {
        [self startAnimation];
        [self addObserver];
        [self resetLabelFrame];
    }	else	{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SOSICM2VehicleStatus *vehicleStatus = [SOSICM2VehicleStatus readSavedVehicleStatus];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (vehicleStatus)      [self configSelfWithICMVehicleStatus:vehicleStatus];
                else                    [self resetLabelFrame];
            });
        });
    }
}

- (void)resetLabelFrame		{
    NSArray *leftLabelArray = @[_lastCarDoorCommendsLabel, _carDoorStatusLabel, _engineStatusLabel, _topRoofStatusLabel];
    NSArray *rightLabelArray = @[_sideRoofStatusLabel, _trunkStatusLabel, _lightStatusLabel, _doubelFlashStatusLabel];
    
    BOOL isIphone5S = SCREEN_MIN_LENGTH <= 320;
    
    if (isIphone5S) 	_lineView1.left = 12;
    
    // 重排左侧 Label
    float topValue = 42.f;
    for (int i = 0; i < leftLabelArray.count; i ++) {
        UILabel *label = leftLabelArray[i];
        [label sizeToFit];
        if (label.hidden == NO) {
            if (isIphone5S)     {
                label.left = _lineView1.right + 5;
                label.font = [UIFont systemFontOfSize:12];
                [label sizeToFit];
            }
            label.top = topValue;
            topValue += label.height + 5.f;
        }
    }
    // 左侧有至少一项
    if (topValue > 42.f) {
        _lineView1.height = topValue + 2 - _lineView1.top;
        if (_lineView2.left < _engineStatusLabel.right + 10)		_lineView2.left = _engineStatusLabel.right + 10;
    }    else    {
        //左侧无对应项
        _lineView1.hidden = YES;
        _lineView2.left = _lineView1.left;
    }
    
    // 重排右侧 Label
    topValue = 42.f;
    for (int i = 0; i < rightLabelArray.count; i ++) {
        UILabel *label = rightLabelArray[i];
        if (isIphone5S)		label.font = [UIFont systemFontOfSize:12];
        [label sizeToFit];
        if (label.hidden == NO) {
            label.top = topValue;
            label.left = _lineView2.right + (isIphone5S ? 5 : 10);
            topValue += label.height + 5.f;
        }
    }
    _lineView2.height = topValue + 2 - _lineView2.top;
    [self.updateTimeLabel sizeToFit];
    self.updateTimeLabel.right = self.refreshButton.left - 5;
    self.refreshFailedImageView.right = self.updateTimeLabel.left - 15;
    self.icon_topRoofUnNormal.left = self.topRoofStatusLabel.right + 3;
    self.icon_sideRoofUnNormal.left = self.sideRoofStatusLabel.right + 3;
}

- (void)addObserver        {
    [[CustomerInfo sharedInstance].icmVehicleStatus addObserverBlockForKeyPath:@"refreshState" block:^(SOSICM2VehicleStatus *obj, NSNumber *oldVal, NSNumber *newVal) { 
        RemoteControlStatus oldState = oldVal.intValue;
        RemoteControlStatus newState = newVal.intValue;
        // 处理请求回调时,会清掉 [CustomerInfo sharedInstance].icmVehicleStatus 的所有属性 , 故加上 RemoteControlStatus_Void 判定
        if (oldState == RemoteControlStatus_InitSuccess || oldState == RemoteControlStatus_Void) {
            switch (newState) {
                case RemoteControlStatus_OperateSuccess:
                    [self endAnimation];
                    [self configSelfWithICMVehicleStatus:[CustomerInfo sharedInstance].icmVehicleStatus];
                    break;
                case RemoteControlStatus_OperateFail:	{
                    [self endAnimation];
                    NSString *updateTimeStr = [NSString stringWithFormat:@"更新于: %@", [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"MM-dd HH:mm" Date:[NSDate date] timeZone:@"GMT+0800"]];
                    self.updateTimeLabel.text = updateTimeStr;
                    self.refreshFailedImageView.hidden = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self resetLabelStateWithICM2ItemStateArray:@[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0)]];
                        [self resetLabelFrame];
                    });
                    break;
                }
                default:
                    break;
            }
        }
    }];
}

- (void)startAnimation	{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 2.f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = LONG_MAX;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshButton.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    });
}

- (void)endAnimation	{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshButton.imageView.layer removeAllAnimations];
    });
}

- (IBAction)refreshButtonTapped 	{
    self.refreshFailedImageView.hidden = YES;
    self.updateTimeLabel.text = [NSString stringWithFormat:@"更新于: %@", @"-- -- : --"];
    [self resetLabelStateWithICM2ItemStateArray:@[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0)]];
    [self resetLabelFrame];
    
    __block __weak __typeof(self) weakSelf = self;
    [self startAnimation];
    
    [SOSVehicleInfoUtil requestICM2VehicleInfoSuccess:^(id result) {
        [weakSelf endAnimation];
        [weakSelf configSelfWithICMVehicleStatus:[CustomerInfo sharedInstance].icmVehicleStatus];
    } Failure:^(id result) {
        [weakSelf endAnimation];
        if ([SOSGreetingManager shareInstance].vehicleStatus == RemoteControlStatus_InitSuccess)	return;
        [weakSelf resetLabelStateWithICM2ItemStateArray:@[@(0), @(0), @(0), @(0), @(0), @(0), @(0), @(0)]];
        NSString *updateTimeStr = [NSString stringWithFormat:@"更新于: %@", [[SOSDateFormatter sharedInstance] dateStrWithDateFormat:@"MM-dd HH:mm" Date:[NSDate date] timeZone:@"GMT+0800"]];
        weakSelf.updateTimeLabel.text = updateTimeStr;
        weakSelf.refreshFailedImageView.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf resetLabelFrame];
        });
    }];
}

- (void)configSelfWithICMVehicleStatus:(SOSICM2VehicleStatus *)icmVehicleStatus  	{
    self.updateTimeLabel.text = [NSString stringWithFormat:@"更新于: %@", (icmVehicleStatus.completionTime.length ? icmVehicleStatus.completionTime : @"-- -- : --")];
    
    // ICM2ItemState 数组, 元素顺序和 LabelArray 严格对照   !!!
    NSArray *ICM2ItemStateArray = @[@(icmVehicleStatus.lastDoorCommands), @(icmVehicleStatus.carDoorStatus), @(icmVehicleStatus.engineStatus), @(icmVehicleStatus.sunroofPositionStatus), @(icmVehicleStatus.windowPositionStatus), @(icmVehicleStatus.trunkStatus), @(icmVehicleStatus.lightStatus), @(icmVehicleStatus.flashStatus)];
    
    
    dispatch_async_on_main_queue(^{
        [self resetLabelStateWithICM2ItemStateArray:ICM2ItemStateArray];
        [self resetLabelFrame];
    });
}

- (void)resetLabelStateWithICM2ItemStateArray:(NSArray *)ICM2ItemStateArray		{
    NSArray *LabelArray = @[_lastCarDoorCommendsLabel, _carDoorStatusLabel, _engineStatusLabel, _topRoofStatusLabel, _sideRoofStatusLabel, _trunkStatusLabel, _lightStatusLabel, _doubelFlashStatusLabel];
    for (int i = 0; i < 8; i++) {
        UILabel *label = LabelArray[i];
        SOSICM2ItemState state = [ICM2ItemStateArray[i] intValue];
        [self configLabel:label WithState:state];
    }
}

- (void)configLabel:(UILabel *)label WithState:(SOSICM2ItemState)state	{
    if (label == self.topRoofStatusLabel)    self.icon_topRoofUnNormal.hidden = (state != SOSICM2ItemState_unNormal);
    if (label == self.sideRoofStatusLabel)    self.icon_sideRoofUnNormal.hidden = (state != SOSICM2ItemState_unNormal);
    int stateStrLength = 1;
    if ([label.text containsString:@"--"] || [label.text containsString:@"异常"] || label == self.lastCarDoorCommendsLabel)    stateStrLength = 2;
    NSString *newText = nil;
    NSString *keyStr = nil;
    switch (state) {
        case SOSICM2ItemState_Non:
            label.highlighted = NO;
            newText = [label.text stringByReplacingCharactersInRange:NSMakeRange(label.text.length - stateStrLength, stateStrLength) withString:@"--"];
            break;
        case SOSICM2ItemState_open:
            label.highlighted = NO;
            if (label == self.lastCarDoorCommendsLabel)		keyStr = @"解锁";
            else											keyStr = @"开";
            newText = [label.text stringByReplacingCharactersInRange:NSMakeRange(label.text.length - stateStrLength, stateStrLength) withString:keyStr];
            break;
        case SOSICM2ItemState_close:
            label.highlighted = YES;
            if (label == self.lastCarDoorCommendsLabel)		keyStr = @"上锁";
            else                                            keyStr = @"关";
            newText = [label.text stringByReplacingCharactersInRange:NSMakeRange(label.text.length - stateStrLength, stateStrLength) withString:keyStr];
            break;
        case SOSICM2ItemState_unNormal:
            label.highlighted = NO;
            newText = [label.text stringByReplacingCharactersInRange:NSMakeRange(label.text.length - stateStrLength, stateStrLength) withString:@"异常"];
            break;
        default:
            break;
    }
    label.text = newText;
}

- (void)dealloc	{
    [self endAnimation];
    [[CustomerInfo sharedInstance].icmVehicleStatus removeObserverBlocksForKeyPath:@"RemoteControlStatus"];
}

@end
