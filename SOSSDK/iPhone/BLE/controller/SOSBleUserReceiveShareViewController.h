//
//  SOSBleReceiveShareViewController.h
//  Onstar
//
//  Created by onstar on 2018/7/25.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"

@interface SOSBleUserReceiveShareViewController : SOSBaseSegmentViewController

@property (nonatomic, copy) void (^delayPerform)(void);

@end
