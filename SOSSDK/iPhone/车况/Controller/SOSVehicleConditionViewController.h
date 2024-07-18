//
//  SOSVehicleConditionViewController.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SOSCarConditionTwo.h"
#import "SOSPDView.h"
#import "SOSCarConditionView.h"

typedef NS_ENUM(NSUInteger ,VEHICLEMODEL){
    ///油耗车辆状态正常
    FuelVehicle_Normal,
    ///油耗车辆状态异常
    FuelVehicle_Unusual,
    //纯电
    BEV_Normal,
    BEV_Unusual,
    PHEV_Normal,  //油电混动
    PHEV_Unusual
};

//typedef NS_ENUM(NSUInteger ,CONDITIONTYPE){
//    INFO_TYPE_ONE,
//    INFO_TYPE_TWO
//};

@interface SOSVehicleConditionViewController : UIViewController

@property(nonatomic, assign) VEHICLEMODEL vehicleModel;



@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;

@property (weak, nonatomic) IBOutlet UIView *vehicleModelView;

@property (weak, nonatomic) IBOutlet UILabel *titleLb;

//@property (weak, nonatomic) IBOutlet UIView *fuelOilCircleView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;


@property (weak, nonatomic) IBOutlet SOSPDView *PDView;
@property (weak, nonatomic) IBOutlet UILabel *timeLB;

- (void)addLeftBarButtonItem;

@end
