//
//  SOSVehicleData.h
//  Onstar
//
//  Created by Genie Sun on 2017/8/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SOSVechicleTableViewCell.h"

@interface SOSVehicleData : NSObject

//+ (void)getVehicleDataService:(NSString *)requestName withCell:(SOSVechicleTableViewCell *)cell andPath:(NSIndexPath *)indexPath Success:(void (^)(id result))completion Failed:(void (^)(void))failCompletion;

//+ (void)getVehicleDataSuccess:(void (^)(id result))completion Failed:(void (^)(id result))failCompletion;

+ (void)getVehicleDataWithParameters:(NSString *)parameters Success:(void (^)(id result))success Failed:(void (^)(id result))failure;

@end
