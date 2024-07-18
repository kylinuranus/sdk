//
//  NSDate+Modify.h
//  SelectDatePickerTest
//
//  Created by jieke on 2019/7/15.
//  Copyright © 2019 jieke. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface NSDate (Modify)

//NSDate转NSString
- (NSString *)toStringWithFormat:(NSString *)format;
/** 获取当前的时间戳 */
+ (NSString *)getCurrentTimestamp;

@end

