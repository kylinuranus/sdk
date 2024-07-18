//
//  LBSOrderRecordListModel.m
//  Onstar
//
//  Created by jieke on 2019/6/20.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "LBSOrderRecordListModel.h"
#import <MJExtension/MJExtension.h>

@interface LBSOrderRecordListModel ()

@end

@implementation LBSOrderRecordListModel

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if ([property.name isEqualToString:@"createDate"]) {
        if (oldValue) {
            NSTimeInterval timestamp = [oldValue doubleValue] / 1000;
            NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:timestamp];
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
            return [fmt stringFromDate:timeData];
        }
    }
    return oldValue;
}
@end
