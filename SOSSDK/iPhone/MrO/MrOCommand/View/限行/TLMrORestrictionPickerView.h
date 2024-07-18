//
//  TLMrORestrictionPickerView.h
//  Onstar
//
//  Created by TaoLiang on 2017/11/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MrORestrictionPickerType) {
    MrORestrictionPickerTypeDate,
    MrORestrictionPickerTypeCity
};

@interface TLMrORestrictionPickerView : UIView
@property (assign, nonatomic) MrORestrictionPickerType pickerType;
@property (copy, nonatomic) void(^picked)(NSString *result, NSUInteger index);
@property (copy, nonatomic) void(^cancel)(NSString *result, NSUInteger index);
@property (strong, nonatomic) id object;



- (void)show;
- (void)hide;
@end
