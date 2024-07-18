//
//  NSDate+Modify.m
//  SelectDatePickerTest
//
//  Created by jieke on 2019/7/15.
//  Copyright © 2019 jieke. All rights reserved.
//

#import "NSDate+Modify.h"

@implementation NSDate (Modify)

#pragma mark NSDate转NSString
- (NSString *)toStringWithFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}
#pragma mark 获取当前的时间戳
+ (NSString *)getCurrentTimestamp {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd",time];
    return timestamp;
}
@end
