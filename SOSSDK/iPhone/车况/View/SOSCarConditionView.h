//
//  SOSCarConditionView.h
//  Onstar
//
//  Created by Genie Sun on 2017/7/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSVehicleConditionViewController.h"

@interface ItemModel :  NSObject
@property (copy, nonatomic) NSString *iconName;
@property (copy, nonatomic) NSString *num;
@property (copy, nonatomic) NSString *unit;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *titleColor;
@end

@interface SOSCarConditionView : SOSBaseXibView

@property (weak, nonatomic) IBOutlet UIImageView *imageView_1;
@property (weak, nonatomic) IBOutlet UILabel *LB_1;
@property (weak, nonatomic) IBOutlet UILabel *info_1;
@property (weak, nonatomic) IBOutlet UILabel *unit_1;

@property (weak, nonatomic) IBOutlet UIImageView *imageView_2;
@property (weak, nonatomic) IBOutlet UILabel *LB_2;
@property (weak, nonatomic) IBOutlet UILabel *info_2;
@property (weak, nonatomic) IBOutlet UILabel *unit_2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView_3;
@property (weak, nonatomic) IBOutlet UILabel *LB_3;
@property (weak, nonatomic) IBOutlet UILabel *info_3;
@property (weak, nonatomic) IBOutlet UILabel *unit_3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthRatio;
@property (weak, nonatomic) IBOutlet UIView *batteryView;
@property (weak, nonatomic) IBOutlet UIView *odoMeterView;
@property (weak, nonatomic) IBOutlet UIView *middleView;

//@property(nonatomic, assign) CONDITIONTYPE model;




//纯电
- (void)configEVView;//电动续航/总里程
//纯油
- (void)configFVView;//机油 总里程

//油电混合
- (void)configPHEVView1;//燃油续航 电动续航 总里程
- (void)configPHEVView2;//机油寿命 综合续航

@end
