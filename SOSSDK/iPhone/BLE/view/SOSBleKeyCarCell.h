//
//  SOSBleKeyCarCell.h
//  Onstar
//
//  Created by onstar on 2018/7/30.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BlePatacSDK/BLEModel.h>

@interface SOSBleKeyCarCell : UITableViewCell

@property (nonatomic, strong) BLEModel *bleEntity;
@property (nonatomic, copy) void(^operationButtonTapBlock)(UIButton *sender);

@end
