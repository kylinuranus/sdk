//
//  SOSCarConditionView.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/26.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSCarConditionView.h"
#import "NSString+Category.h"

@implementation ItemModel

@end

@implementation SOSCarConditionView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configViewWithArray:(NSArray *)dataArray {
    if (dataArray.count == 3) {
        [self fillDataToItem2:dataArray[1]];
    }else if (dataArray.count == 2){
        self.middleView.fd_collapsed = YES;
    }
     [self fillDataToItem1:dataArray.firstObject];
     [self fillDataToItem3:dataArray.lastObject];
}

- (void)fillDataToItem1:(ItemModel *)model {
    
    self.imageView_1.image = [UIImage imageNamed:model.iconName];
    self.LB_1.text = model.num;
    self.info_1.text = model.title;
    self.unit_1.text = model.unit;
    if (model.titleColor) {
        self.LB_1.textColor = [UIColor colorWithHexString:model.titleColor];
    }else {
        self.LB_1.textColor = UIColorHex(#69696C);
    }
}

- (void)fillDataToItem2:(ItemModel *)model {
    self.imageView_2.image = [UIImage imageNamed:model.iconName];
    self.LB_2.text = model.num;
    self.info_2.text = model.title;
    self.unit_2.text = model.unit;
    if (model.titleColor) {
        self.LB_2.textColor = [UIColor colorWithHexString:model.titleColor];;
    }else {
        self.LB_2.textColor = UIColorHex(#69696C);
    }
    
}

- (void)fillDataToItem3:(ItemModel *)model {
    self.imageView_3.image = [UIImage imageNamed:model.iconName];
    self.LB_3.text = model.num;
    self.info_3.text = model.title;
    self.unit_3.text = model.unit;
    if (model.titleColor) {
        self.LB_3.textColor = [UIColor colorWithHexString:model.titleColor];;
    }else {
        self.LB_3.textColor = UIColorHex(#69696C);
    }
}

//纯电
- (void)configEVView {//电动续航/总里程
    ItemModel *model1 = [self evRange];
    ItemModel *model2 = [self oDoMeter];
    [self configViewWithArray:@[model1,model2]];
}

//纯油
- (void)configFVView {//机油 总里程
    ItemModel *model1 = [self oilLife];
    ItemModel *model2 = [self oDoMeter];
    SOSVehicle *vehicle = CustomerInfo.sharedInstance.userBasicInfo.currentSuite.vehicle;
    if (vehicle.engineAirFilterMonitorStatusSupported) {
        ItemModel *modelAirFilter = self.airFilter;
        [self configViewWithArray:@[model1, modelAirFilter, model2]];
    }else {    
        [self configViewWithArray:@[model1,model2]];
    }

}

//油电混合
- (void)configPHEVView1 {//燃油续航 电动续航 总里程
    ItemModel *model1 = [self fuelLavel];
    ItemModel *model2 = [self evRange];
    ItemModel *model3 = [self oDoMeter];
    [self configViewWithArray:@[model1,model2,model3]];
}

- (void)configPHEVView2 {//机油寿命 综合续航
    ItemModel *model1 = [self oilLife];
    ItemModel *model2 = [self evTotleRange];
    [self configViewWithArray:@[model1,model2]];
}

- (ItemModel *)evTotleRange {
    ItemModel *model2 = [ItemModel new];
    model2.title = @"综合续航里程";
    model2.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(9)"];
    if(![Util isValidNumber:[CustomerInfo sharedInstance].evTotleRange]){
        model2.num = @"--";
    } else {
        model2.num = [CustomerInfo sharedInstance].evTotleRange;
    }
    model2.unit = @"公里";
    return model2;
}

- (ItemModel *)oilLife {
    ItemModel *model1 = [ItemModel new];
    model1.title = @"机油寿命";
    if([Util isValidNumber:[CustomerInfo sharedInstance].oilLife]) {
        model1.num = [NSString stringWithFormat:@"%@%%", [CustomerInfo sharedInstance].oilLife];
    }else {
        model1.num = @"--";
    }
    VehicleStatus oilStatus = [SOSVehicleVariousStatus oilStatus]; //机油
    if (oilStatus == OIL_RED) {
        model1.iconName = @"Icon／60x60／icon_condition_oil_def_60x60(2)";
        model1.titleColor = @"#C50000";
    }else if (oilStatus == OIL_YELLOW) {
        model1.iconName = @"Icon／60x60／icon_condition_oil_def_60x60(1)";
        model1.titleColor = @"#F18F19";
    }else if (oilStatus == OIL_GREEN) {
        model1.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60"];
        model1.titleColor = @"#69696C";
    }else {
        model1.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(3)"];
        model1.titleColor = @"#69696C";
    }
    model1.unit = @"";
    return model1;
}

-(ItemModel *)oDoMeter {
    ItemModel *model3 = [ItemModel new];
    model3.title = @"总里程数";
    
    if ([Util vehicleIsBEV] || [Util vehicleIsPHEV]) {
        model3.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(10)"];
    }else {
        model3.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(9)"];
    }
    if ([Util isValidNumber:[CustomerInfo sharedInstance].oDoMeter]) {
        model3.num = [CustomerInfo sharedInstance].oDoMeter;
    }else{
        model3.num = @"--";
    }
    model3.unit = @"公里";
    return model3;
}

-(ItemModel *)fuelLavel {
    ItemModel *model1 = [ItemModel new];
    model1.title = @"燃油余量";
    if(![Util isValidNumber:[CustomerInfo sharedInstance].fuelLavel]){
        model1.num = @"--";
    } else {
        model1.num = [NSString stringWithFormat:@"%@%%", [CustomerInfo sharedInstance].fuelLavel];
    }
    VehicleStatus gasStatus = [SOSVehicleVariousStatus gasStatus];
    if (gasStatus == GAS_RED) {
        model1.iconName = @"Icon／60x60／icon_condition_oil_def_60x60(7)";
        model1.titleColor = @"#C50000";
    }else if (gasStatus == GAS_YELLOW) {
        model1.iconName = @"Icon／60x60／icon_condition_oil_def_60x60(6)";
        model1.titleColor = @"#F18F19";
    }else if (gasStatus == GAS_GREEN_GOOD) {
        model1.iconName =  [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(5)"];
        model1.titleColor = @"#69696C";
    }else {
        model1.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(8)"];
        model1.titleColor = @"#69696C";
    }
    model1.unit = @"";
    return model1;
}

-(ItemModel *)evRange {
    ItemModel *model2 = [ItemModel new];
    model2.title = @"电动续航里程";
    model2.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_oil_def_60x60(4)"];
    
    NSString *range = [Util vehicleIsPHEV]? [CustomerInfo sharedInstance].evRange : [CustomerInfo sharedInstance].bevBatteryRange;
    if(![Util isValidNumber:range]){
        model2.num = @"--";
    } else {
        model2.num = range;
    }
    model2.unit = @"公里";
    return model2;
}


/// for my21 车型
- (ItemModel *)airFilter {
    ItemModel *model = ItemModel.new;
    model.title = @"空气滤清器";
    model.iconName = [NSString appendCdSuff:@"Icon／60x60／icon_condition_filter-element_def_60x60"];
    NSString *value = CustomerInfo.sharedInstance.airFilterStatus;
    model.num = [Util isValidNumber:value] ? [value stringByAppendingString:@"%"] : @"--";
    return model;
}

@end
