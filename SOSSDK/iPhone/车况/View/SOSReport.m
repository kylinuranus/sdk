//
//  SOSReport.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/28.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSReport.h"
#import "SOSGreetingManager.h"

@implementation SOSReport

- (void)awakeFromNib {
    [super awakeFromNib];
//     [self refresh];
//    @weakify(self);
//    [RACObserve([SOSGreetingManager shareInstance], vehicleStatus) subscribeNext:^(id x) {
//        @strongify(self);
//        if ([x integerValue] == RemoteControlStatus_OperateSuccess) {
//            [self refresh];
//        }
//    }];
}

- (void)refresh {
    self.timeLB.text = [NSString stringWithFormat:@"%@年%@月%@日 %@:%@:%@", [CustomerInfo sharedInstance].timeYear, [CustomerInfo sharedInstance].timeMonth,[CustomerInfo sharedInstance].timeDay, [CustomerInfo sharedInstance].timeHour, [CustomerInfo sharedInstance].timeMinute, [CustomerInfo sharedInstance].timeSecond];
}

@end
