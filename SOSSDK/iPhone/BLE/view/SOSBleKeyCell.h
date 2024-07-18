//
//  SOSBleKeyCell.h
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSCardBaseCell.h"
#import <BlePatacSDK/BLEModel.h>

@interface SOSBleKeyCell : UITableViewCell

@property (nonatomic, copy) void(^reConnectBlock)(BLEModel *bleModel);

- (void)refreshWithResp:(id)response;

@end
