//
//  SOSVehicleUnitFeatureItem.h
//  Onstar
//
//  Created by Onstar on 2018/3/7.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSVehicleUnitFeatureItem : NSObject
@property(nonatomic,copy)NSString *featureName;
@property(nonatomic,assign)BOOL value;
@property(nonatomic,copy)NSString *valueType;
@property(nonatomic,strong)id featureSettings;
@end
