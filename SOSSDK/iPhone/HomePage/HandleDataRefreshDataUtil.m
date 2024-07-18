//
//  HomePageViewControllerUtil.m
//  Onstar
//
//  Created by Apple on 16/6/29.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSCardUtil.h"
#import "CustomerInfo.h"
#import "SOSCheckRoleUtil.h"
#import "SOSWebViewController.h"
#import "HandleDataRefreshDataUtil.h"
#import "SOSGreetingManager.h"

//#define HideSmartHome 0

@implementation HandleDataRefreshDataUtil

/**
 *  设置车辆信息
 *
 *  @param dic 车辆信息
 */
+ (void)setupVehicleStatusInfo:(NSDictionary *)dic
{
    
    NSString *temp = nil;
    if (dic) {
         NSArray *dataArray = [[[dic objectForKey:@"commandResponse"]objectForKey:@"body"] objectForKey:@"DiagnosticResponse"];
        if(dataArray==nil){
            dataArray = [[[dic objectForKey:@"commandResponse"]objectForKey:@"body"] objectForKey:@"diagnosticResponse"];
        }
            
        NSInteger dataCount = [dataArray count];
        for (int i =0; i<dataCount; i++) {
            NSString * keyName = [dataArray[i] objectForKey:@"name"];
#pragma mark -燃油余量
            if ([keyName isEqualToString:@"FUEL TANK INFO"]) {
                //to be selete
//                DiagnosticResponse *response = [[DiagnosticResponse alloc]initWithDictionary:[dataArray objectAtIndex:i]];
                DiagnosticResponse *response = [DiagnosticResponse mj_objectWithKeyValues:[dataArray objectAtIndex:i]];
                NSArray *elementArray = response.diagnosticElement;
                NSInteger elementCount = [elementArray count];
                for (int j =0; j<elementCount; j++) {
                    DiagnosticElement *element = [elementArray objectAtIndex:j];
                    if([element.name isEqualToString:@"FUEL LEVEL"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        
                        NSString *newValue = @"--";
                        int intValue;
                        
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        
                        if ([Util isValidNumber:temp])
                            
                        {
                            NSString *fuelLevelEx = @"[0-9.]{1,}";
                            NSPredicate *fuelLevelPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", fuelLevelEx];
                            if ([fuelLevelPredicate evaluateWithObject:element.value] != YES)
                            {
                                newValue = @"--";
                            }
                            else
                            {
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }
                        }
                        else {
                            newValue = @"--";
                        }
                        
                        [CustomerInfo sharedInstance].fuelLavel = newValue;
                    }
                }
                
            }
#pragma mark -胎压
            else if([keyName isEqualToString:@"TIRE PRESSURE"]){
                //to be delete
                //DiagnosticResponse *response = [[DiagnosticResponse alloc]initWithDictionary:[dataArray objectAtIndex:i]];
                DiagnosticResponse *response = [DiagnosticResponse mj_objectWithKeyValues:[dataArray objectAtIndex:i]];
                NSArray *elementArray = response.diagnosticElement;
                NSInteger elementCount = [elementArray count];
                for (int j =0; j<elementCount; j++) {
                    DiagnosticElement *element = [elementArray objectAtIndex:j];
                    if ([element.name isEqualToString:@"TIRE PRESSURE LF"]	) {
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        NSString *newValue;
                        int intValue;
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([Util isValidNumber:temp])
                        {
                            if([element.value floatValue] >= 0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                            
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        
                        [CustomerInfo sharedInstance].tirePressureLF = newValue;
                        [CustomerInfo sharedInstance].tirePressureLFStatus = element.message;
                    }else if([element.name isEqualToString:@"TIRE PRESSURE LR"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        NSString *newValue;
                        int intValue;
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([Util isValidNumber:temp])
                        {
                            if([element.value floatValue] >= 0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        [CustomerInfo sharedInstance].tirePressureLR = newValue;
                        [CustomerInfo sharedInstance].tirePressureLRStatus = element.message;
                        
                    }else if([element.name isEqualToString:@"TIRE PRESSURE RF"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        NSString *newValue;
                        int intValue;
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([Util isValidNumber:temp])
                        {
                            if([element.value floatValue] >= 0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        [CustomerInfo sharedInstance].tirePressureRF = newValue;
                        [CustomerInfo sharedInstance].tirePressureRFStatus = element.message;
                    }
                    else if([element.name isEqualToString:@"TIRE PRESSURE RR"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        NSString *newValue;
                        int intValue;
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([Util isValidNumber:temp])
                        {
                            if([element.value floatValue] >=0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        
                        [CustomerInfo sharedInstance].tirePressureRR = newValue;
                        [CustomerInfo sharedInstance].tirePressureRRStatus = element.message;
                        
                    }else if([element.name isEqualToString:@"TIRE PRESSURE PLACARD FRONT"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        
                        NSString *newValue;
                        int intValue;
                        temp = [element.value  stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([Util isValidNumber:temp])
                            
                        {
                            if([element.value floatValue] >= 0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        
                        [CustomerInfo sharedInstance].tirePressurePlacardFront = newValue;
                    }else if([element.name isEqualToString:@"TIRE PRESSURE PLACARD REAR"]){
                        NSLog(@"%@-----%@%@",element.name,element.value, element.unit);
                        NSString *newValue;
                        int intValue;
                        temp = [element.value stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if ([Util isValidNumber:temp])
                        {
                            if([element.value floatValue] >= 0){
                                intValue = [element.value floatValue] + 0.0;
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }else{
                                newValue = @"KPA";
                            }
                        }
                        else {
                            newValue = @"--KPA";
                        }
                        
                        [CustomerInfo sharedInstance].tirePressurePlacardRear = newValue;
                    }
                }
            }
#pragma mark -总里程
            else if([keyName isEqualToString:@"ODOMETER"]){
                if (![Util vehicleIsBEV]) {		// 燃油车,PHEV
                   
                    NSDictionary *dic = nil;
                    NSArray *newArray = nil;
                    if ([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSDictionary class]]) {
                        dic = [dataArray[i] objectForKey:@"diagnosticElement"];
                        NSLog(@"%@-----%@%@",[dic objectForKey:@"name"],[dic objectForKey:@"value"],[dic objectForKey:@"unit"]);
                    }else if([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSArray class]]){
                        newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                    }
                    NSString *newValue = @"--";
                    if (dic) {
                        temp =  [[dic objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([Util isValidNumber:temp])
                            
                        {
                            int intValue = ([[dic objectForKey:@"value"] floatValue]);
                            newValue = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue = @"--";
                        }
                    }else if(newArray){
                        temp = [[[newArray objectAtIndex:0] objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([Util isValidNumber:temp])
                        {
                            int intValue = ([[[newArray objectAtIndex:0] objectForKey:@"value"] floatValue]);
                            newValue = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue = @"--";
                        }
                    }
                    [CustomerInfo sharedInstance].oDoMeter = newValue;
                }
                
            }else if([keyName isEqualToString:@"LIFETIME EV ODOMETER"]){	// 纯电车
                if ([Util vehicleIsBEV]) {
                    NSDictionary *dic = nil;
                    NSArray *newArray = nil;
                    if ([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSDictionary class]]) {
                        dic = [dataArray[i] objectForKey:@"diagnosticElement"];
                        NSLog(@"%@-----%@%@",[dic objectForKey:@"name"],[dic objectForKey:@"value"],[dic objectForKey:@"unit"]);
                    }else if([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSArray class]]){
                        newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                    }
                    NSString *newValue = @"--";
                    if (dic) {
                        temp =  [[dic objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([Util isValidNumber:temp])
                            
                        {
                            int intValue = ([[dic objectForKey:@"value"] floatValue]);
                            newValue = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue = @"--";
                        }
                    }else if(newArray){
                        temp = [[[newArray objectAtIndex:0] objectForKey:@"value"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([Util isValidNumber:temp])
                        {
                            int intValue = ([[[newArray objectAtIndex:0] objectForKey:@"value"] floatValue]);
                            newValue = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue = @"--";
                        }
                    }
                    [CustomerInfo sharedInstance].oDoMeter = newValue;
                }
                
            }
            
#pragma mark -机油寿命 - CR使用四舍五入
            else if([keyName isEqualToString:@"OIL LIFE"]){
                NSDictionary *dic = nil;
                NSArray *newArray = nil;
                if ([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSDictionary class]]) {
                    dic = [dataArray[i] objectForKey:@"diagnosticElement"];
                    NSLog(@"%@-----%@%@",[dic objectForKey:@"name"],[dic objectForKey:@"value"],[dic objectForKey:@"unit"]);
                }else if([[dataArray[i] objectForKey:@"diagnosticElement"] isKindOfClass:[NSArray class]]){
                    newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                }
                
                NSString *newValue = @"--";
                int intValue;
                if (dic) {
                    temp = [[dic objectForKey:@"value"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    
                    if ([Util isValidNumber:temp])
                    {
                        intValue = temp.floatValue + 0.5;
                        newValue = [NSString stringWithFormat:@"%d", intValue];
                    }
                    else {
                        newValue = @"--";
                    }
                }else if(newArray){
                    temp = [[[newArray objectAtIndex:0] objectForKey:@"value"] stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    
                    if ([Util isValidNumber:temp])
                    {
                        intValue = temp.floatValue + 0.5;
                        newValue = [NSString stringWithFormat:@"%d", intValue];
                        if (newValue < 0) {
                            newValue = @"--";
                        }
                    }
                    else {
                        newValue = @"--";
                    }
                }
                
                [CustomerInfo sharedInstance].oilLife = newValue;
            }
#pragma mark -充电电压
            else if([keyName isEqualToString:@"EV PLUG VOLTAGE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                }
                if ([temp length]>0&&![temp isEqualToString:@"0"])
                    
                {
                    newValue = [NSString stringWithFormat:@"%@", [[newArray objectAtIndex:0] objectForKey:@"value"]];
                    //                    if (([newValue hasSuffix:@"240V)"]) || ([newValue hasSuffix:@"220V)"]) || ([newValue hasSuffix:@"240V"]) || ([newValue hasSuffix:@"220V"]))
                    //                        newValue = @"220V";
                    //                    else if ([newValue hasSuffix:@"120V"] || [newValue hasSuffix:@"120V)"])
                    //                        newValue = @"220V";
                    //                    else
                    //                        newValue = @"---V";
                }
                else {
                    newValue = @"---V";
                }
                [CustomerInfo sharedInstance].evVoltage = newValue;
                
            }
#pragma mark -开始时间
            else if([keyName isEqualToString:@"EV SCHEDULED CHARGE START"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    for (int j = 0; j < newArray.count; j++) {
                        if ([[[newArray objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"SCHED CHG START 240V"]) {
                            temp =  [[[newArray objectAtIndex:j] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([temp length]>0)
                                
                            {
                                newValue = [NSString stringWithFormat:@"%@", temp];
                            }
                            else {
                                newValue = @"--";
                            }
                        }
                        
                    }
                    
                }
                else {
                    newValue = @"--";
                }
                [CustomerInfo sharedInstance].chargeStartTime = newValue;
                
            }
            
#pragma mark -预计9：00充电完成
            else if([keyName isEqualToString:@"EV ESTIMATED CHARGE END"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    for (int j = 0; j < newArray.count; j++) {
                        if ([[[newArray objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"EST CHG END 240V"]) {
                            temp =  [[[newArray objectAtIndex:j] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        }
                        if ([temp length]>0)
                            
                        {
                            newValue = [NSString stringWithFormat:@"%@", temp];
                        }
                        else {
                            newValue = @"--";
                        }
                    }
                    
                }
                else {
                    newValue = @"--";
                }
                
                [CustomerInfo sharedInstance].chargeEndTime = newValue;
            }
            
#pragma mark -电池电量百分比
            else if([keyName isEqualToString:@"EV BATTERY LEVEL"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                if ([Util isValidNumber:temp])
                    
                {
                    int intValue = ([[[newArray objectAtIndex:0] objectForKey:@"value"] floatValue]);
                    newValue = [NSString stringWithFormat:@"%d", intValue];
                }
                else {
                    newValue = @"--";
                }
                
                [CustomerInfo sharedInstance].batteryLevel = newValue;
            }
#pragma mark -是否插上电源
            else if([keyName isEqualToString:@"EV PLUG STATE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
                if ([temp length] > 0)
                {
                    newValue = [NSString stringWithFormat:@"%@", [[newArray objectAtIndex:0] objectForKey:@"value"]];
                }
                else {
                    newValue = @"icon_not_plugged_in.png";
                }
                [CustomerInfo sharedInstance].plugInState = newValue;
            }
#pragma mark -获取charge mode
            else if([keyName isEqualToString:@"GET CHARGE MODE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
                if ([temp length] > 0)
                    
                {
                    newValue = [NSString stringWithFormat:@"%@", [[newArray objectAtIndex:0] objectForKey:@"value"]];
                }
                else {
                    newValue = @"icon_not_plugged_in.png";
                }
                [CustomerInfo sharedInstance].chargeModeHome = newValue;
            }
#pragma mark -电动续航里程  -综合续航里程？？
            else if([keyName isEqualToString:@"VEHICLE RANGE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                NSLog(@"%@-----%@%@",[dic objectForKey:@"name"],[dic objectForKey:@"value"],[dic objectForKey:@"unit"]);
                
                NSString *newValue = @"--";
                NSString *newValue2 = @"--";
                if (newArray)
                {for (int j = 0; j < newArray.count; j++) {
                    if ([[[newArray objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"EV RANGE"]) {
                        temp =  [[[newArray objectAtIndex:j] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([temp length] > 0)
                            
                        {
                            int intValue = ([temp floatValue]);
                            newValue = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue = @"--";
                        }
                    }
                    if ([[[newArray objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"TOTAL RANGE"]) {
                        temp =  [[[newArray objectAtIndex:j] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([temp length] > 0)
                        {
                            int intValue = ([temp floatValue]);
                            newValue2 = [NSString stringWithFormat:@"%d", intValue];
                        }
                        else {
                            newValue2 = @"--";
                        }
                    }
                }
                }else {
                    newValue = @"--";
                    newValue2 = @"--";
                }
                
                [CustomerInfo sharedInstance].evRange = newValue;
                
                [CustomerInfo sharedInstance].evTotleRange = newValue2;
            }
#pragma mark -可行驶里程？= 综合续航里程
            else if([keyName isEqualToString:@"VEHICLE RANGE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                NSLog(@"%@-----%@%@",[dic objectForKey:@"name"],[dic objectForKey:@"value"],[dic objectForKey:@"unit"]);
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                if ([Util isValidNumber:temp])
                {
                    int intValue = ([[[newArray objectAtIndex:0] objectForKey:@"value"] floatValue]);
                    newValue = [NSString stringWithFormat:@"%d", intValue];
                }
                else {
                    newValue = @"--";
                }
                [CustomerInfo sharedInstance].vehicleRange = newValue;
            }
#pragma mark - BEV 电动车 续航里程
            else if ([keyName isEqualToString:@"BATTERY RANGE"]) {
                NSArray *newArray = dataArray[i][@"diagnosticElement"];
                NSDictionary *batteryRangeDic = newArray.firstObject;
                NSLog(@"%@-----%@%@",[batteryRangeDic objectForKey:@"name"],[batteryRangeDic objectForKey:@"value"],[batteryRangeDic objectForKey:@"unit"]);
                NSString *newValue = @"--";
                temp = [batteryRangeDic[@"value"] stringByTrim];
                if ([Util isValidNumber:temp]) {
                    newValue = [NSString stringWithFormat:@"%ld", (long)temp.integerValue];
                }
                [CustomerInfo sharedInstance].bevBatteryRange = newValue;
            }
#pragma mark - BEV 电动车 电池电量
            else if ([keyName isEqualToString:@"BATTERY STATUS"]) {
                NSArray *newArray = dataArray[i][@"diagnosticElement"];
                NSDictionary *batteryStatusDic = newArray.firstObject;
                NSLog(@"%@-----%@%@",[batteryStatusDic objectForKey:@"name"],[batteryStatusDic objectForKey:@"value"],[batteryStatusDic objectForKey:@"unit"]);
                NSString *newValue = @"--";
                temp = [batteryStatusDic[@"value"] stringByTrim];
                if ([Util isValidNumber:temp]) {
                    newValue = [NSString stringWithFormat:@"%ld", (long)temp.integerValue];
                }
                [CustomerInfo sharedInstance].bevBatteryStatus = newValue;
            }
            
#pragma mark - My21 GB 空气滤清器
            else if ([keyName isEqualToString:@"ENGINE AIR FILTER MONITOR STATUS"]) {
                NSArray *newArray = dataArray[i][@"diagnosticElement"];
                NSDictionary *airFilterStatusDic = newArray.firstObject;
                NSLog(@"%@-----%@%@",[airFilterStatusDic objectForKey:@"name"],[airFilterStatusDic objectForKey:@"value"],[airFilterStatusDic objectForKey:@"unit"]);
                NSString *newValue = @"--";
                temp = [airFilterStatusDic[@"value"] stringByTrim];
                if ([Util isValidNumber:temp]) {
                    newValue = [NSString stringWithFormat:@"%ld", (long)temp.integerValue];
                }
                [CustomerInfo sharedInstance].airFilterStatus = newValue;
            }
#pragma mark - My21 GB 刹车片
            else if([keyName isEqualToString:@"BRAKE PAD LIFE"]){
                NSArray<NSDictionary *> *elements = dataArray[i][@"diagnosticElement"];
                if (elements.count <= 0) {
                    break;
                }
                [elements enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *name = obj[@"name"];
                    if ([name isEqualToString:@"BRAKE PAD LIFE FRONT"]) {
                        NSString *value = [obj[@"value"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                        CustomerInfo.sharedInstance.brakePadLifeFront = [Util isValidNumber:value] > 0 ? [NSString stringWithFormat:@"%d", value.intValue] : @"--";
                    }else if ([name isEqualToString:@"BRAKE PAD LIFE REAR"]) {
                        NSString *value = [obj[@"value"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                        CustomerInfo.sharedInstance.brakePadLifeRear = [Util isValidNumber:value] > 0 ? [NSString stringWithFormat:@"%d", value.intValue] : @"--";
                    }else if ([name isEqualToString:@"BRAKE PAD LIFE STATUS INDICATION REQUEST"]) {
                        CustomerInfo.sharedInstance.brakePadLifeStatus = obj[@"value"];

                    }
                }];
            }
#pragma mark -上次行驶里程
            else if([keyName isEqualToString:@"LAST TRIP DISTANCE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    for (int j = 0; j < newArray.count; j++) {
                        if ([[[newArray objectAtIndex:j] objectForKey:@"name"] isEqualToString:@"LAST TRIP TOTAL DISTANCE"]) {
                            temp =  [[[newArray objectAtIndex:j] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            if ([temp length] > 0)
                            {
                                int intValue = ([temp floatValue]);
                                newValue = [NSString stringWithFormat:@"%d", intValue];
                            }
                            else {
                                newValue = @"--";
                            }
                        }
                    }
                }else {
                    newValue = @"--";
                }
                [CustomerInfo sharedInstance].lastTripDistance = newValue;
            }
#pragma mark -上次油耗
            else if([keyName isEqualToString:@"LAST TRIP FUEL ECONOMY"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([temp length] > 0)
                    {
                        int intValue = ([temp floatValue]);
                        newValue = [NSString stringWithFormat:@"%d", intValue];
                    }
                    else {
                        newValue = @"--";
                    }
                }
                [CustomerInfo sharedInstance].lastTripFuelEcon = newValue;
            }
#pragma mark -充电状态
            else if([keyName isEqualToString:@"EV CHARGE STATE"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                if ([temp length]>0)
                    
                {
                    newValue = [NSString stringWithFormat:@"%@", [[newArray objectAtIndex:0] objectForKey:@"value"]];
                }
                else {
                    newValue = @"--";
                }
                [CustomerInfo sharedInstance].chargeState = newValue;
            }
#pragma mark -平均油耗
            else if([keyName isEqualToString:@"LIFETIME FUEL ECON"]){
                NSArray *newArray = [dataArray[i] objectForKey:@"diagnosticElement"];
                
                NSString *newValue = @"--";
                if (newArray) {
                    temp =  [[[newArray objectAtIndex:0] objectForKey:@"value"]stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([temp length] > 0)
                    {
                        int intValue = ([temp floatValue]);
                        newValue = [NSString stringWithFormat:@"%d", intValue];
                    }
                    else {
                        newValue = @"--";
                    }
                }
                [CustomerInfo sharedInstance].lifeTimeFuelEcon = newValue;
            }
        }

        //设置更新时间
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:XML_DATE_FORMAT];
        
        NSMutableString *tempCompleteTime = nil;

        if ([[[dic objectForKey:@"commandResponse"]objectForKey:@"completionTime"] length] > 0)
        {
            tempCompleteTime = [[NSMutableString alloc] initWithString:[[dic objectForKey:@"commandResponse"]objectForKey:@"completionTime"]];
        }
        
        
        NSInteger length = [tempCompleteTime length];
        
        if (length > 23)
        {
            [tempCompleteTime replaceCharactersInRange: NSMakeRange(23, length - 23) withString:@""];
            NSDate *date = [Util convertGTM0ToGTM8WithDate:[df dateFromString:tempCompleteTime]];
            [df setDateFormat:DATE_YEAR];
            NSString *year = [df stringFromDate:date];
            [df setDateFormat:DATE_MONTH];
            NSString *month = [df stringFromDate:date];
            [df setDateFormat:DATE_DAY];
            NSString *day = [df stringFromDate:date];
            [df setDateFormat:DATE_HOUR];
            NSString *hour = [df stringFromDate:date];
            [df setDateFormat:DATE_MINUTE];
            NSString *minute = [df stringFromDate:date];
            [df setDateFormat:DATE_SECOND];
            NSString *second = [df stringFromDate:date];
            
            [CustomerInfo sharedInstance].timeYear = year;
            [CustomerInfo sharedInstance].timeMonth = month;
            [CustomerInfo sharedInstance].timeDay = day;
            [CustomerInfo sharedInstance].timeHour = hour;
            [CustomerInfo sharedInstance].timeMinute = minute;
            [CustomerInfo sharedInstance].timeSecond = second;
        }
        else
        {
            [CustomerInfo sharedInstance].timeYear = nil;
            [CustomerInfo sharedInstance].timeMonth = nil;
            [CustomerInfo sharedInstance].timeDay = nil;
            [CustomerInfo sharedInstance].timeHour = nil;
            [CustomerInfo sharedInstance].timeMinute = nil;
            [CustomerInfo sharedInstance].timeSecond = nil;
        }
    }
    
    
    
    
    if( [Util vehicleIsBEV]){
    
         //电动车续航里程 如果为空或不是数字，在取EV RANGE字段
        if( ![CustomerInfo sharedInstance].bevBatteryRange ||
           [[CustomerInfo sharedInstance].bevBatteryRange isEqual:[NSNull null]]||
           ![Util isValidNumber:[CustomerInfo sharedInstance].bevBatteryRange]){
            
            
            [CustomerInfo sharedInstance].bevBatteryRange = [CustomerInfo sharedInstance].evRange;
            
        }
        
         //电动车电池电量 如果为空或不是数字，取batteryLevel字段
        if( ![CustomerInfo sharedInstance].bevBatteryStatus ||
           [[CustomerInfo sharedInstance].bevBatteryStatus isEqual:[NSNull null]]||
           ![Util isValidNumber:[CustomerInfo sharedInstance].bevBatteryStatus]){
            
            
            [CustomerInfo sharedInstance].bevBatteryStatus = [CustomerInfo sharedInstance].batteryLevel;
            
        }
        
   }
    
    
    //记录入数据库
    [CustomerInfo insertInto:[CustomerInfo sharedInstance].userBasicInfo.currentSuite.vehicle.vin];

}

#pragma mark -设置lable
+ (NSMutableAttributedString *)AttributeString:(NSString *)str andRearNumber:(int)rear {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    int bigSize =30;
    int smallSize =17;
    if ([Util isDeviceiPhone5]||[Util isDeviceiPhone4]) {
        bigSize = 24;
        smallSize = 12;
    }
    //数值 98%
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:bigSize] range:NSMakeRange(0, str.length - rear)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"18acfe"] range:NSMakeRange(0, str.length - rear)];
    //单位：%；km；kpa
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:smallSize] range:NSMakeRange(str.length - rear,  rear)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"18acfe"] range:NSMakeRange(str.length - rear,  rear)];
    return attributedString;
}

+ (BOOL)isValidPercentValue:(NSString *)value{
    NSString *valueEx = @"[0-9.]{1,}";
    NSPredicate *valuePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", valueEx];
    return [valuePredicate evaluateWithObject:value];
}


#pragma mark 是否显示驾驶评分
+ (BOOL)showDriveScore	{
    //已登录、gen10 & owner、 非PHEV && 非BEV
    return [[LoginManage sharedInstance] isLoadingUserBasicInfoReady] &&
            [Util vehicleIsG10] &&
            [SOSCheckRoleUtil isOwner] &&
            ![Util vehicleIsPHEV] &&
    		![Util vehicleIsBEV];
}

+ (void)drivingBehavior:(UINavigationController *)navi	{
    [SOSCardUtil routerToDrivingScoreH5:navi];
}

+ (void)oilConsumptionRanking:(UINavigationController *)navi	{
    NSString *linkurl = DRIVING_OIL_CONSUMPTION_DEFAULTURL;
    if([[LoginManage sharedInstance] isLoadingUserBasicInfoReady] &&([Util vehicleIsPHEV]||[Util vehicleIsEV])){
        linkurl = DRIVING_ENERGINE_CONSUMPTION_URL;
    }
    SOSWebViewController *vc = [[SOSWebViewController alloc] initWithUrl:linkurl];
    [navi pushViewController:vc animated:YES];
}
@end
