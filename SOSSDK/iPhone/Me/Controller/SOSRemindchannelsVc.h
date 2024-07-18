//
//  SOSRemindchannelsVc.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/14.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    StolenRemind = 0, //车辆报警提示渠道设置 tan
    TestReport, //车辆检测报告提醒渠道设置 ovd
    FaultDiagnosis, //车辆故障诊断提醒推送渠道设置 DA
    SmartDriver, //驾驶行为
    FUELEconomy, //油耗排名
    Ubi, //车联保险
    EnergyEconomy, //能耗排名
    ICM2CarDoorOpenAlert,	//车门未关
    ICM2TrunkOpenAlert,		//后备箱未关
    ICM2WindowOpenAlert,	//车窗未关
    ICMSunroofOpenAlert,	//天窗未关
    ICM2LightOpenAlert,		//大灯未关
    ICM2EngineOpenAlert,	//发动机未熄火
    ICM2FlashOpenAlert,		//警示灯未关
} channelsType;

typedef enum : NSUInteger {
    addcell = 0,
    deleteCell,
} cellType;

//typedef NS_ENUM(NSUInteger, ValidityType) {
//    PeriodOfValidity,    //gen10流量包在有效期内或gen9服务包在有效期内
//    Gen10TrafficOver,    //Gen10流量包过期
//    gen9ServiceOver,    //Gen9服务包过期
//};

@interface SOSRemindchannelsVc : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *table;
@property(nonatomic, assign) channelsType channelsType;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil channerlsType:(channelsType)type;
@property (weak, nonatomic) IBOutlet UILabel *gen9Tip;
@property (weak, nonatomic) IBOutlet UILabel *gen10Tip;

@end
