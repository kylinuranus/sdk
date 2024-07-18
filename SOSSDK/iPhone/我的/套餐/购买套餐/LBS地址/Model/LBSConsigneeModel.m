//
//  LBSConsigneeModel.m
//  LBSTest
//
//  Created by jieke on 2019/6/13.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "LBSConsigneeModel.h"

@implementation LBSConsigneeModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"consigneeAddress":@"deliveryAddr",
             @"consigneeName":@"deliveryName",
             @"consigneePhone":@"deliveryPhone"};
}
@end
