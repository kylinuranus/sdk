//
//  SOSVehicleSettingCalendarView.h
//  Onstar
//
//  Created by Creolophus on 2020/2/20.
//  Copyright © 2020 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface SOSVehicleSettingCalendarView : UIView
@property (strong, nonatomic, readonly) NSDate *selectDate;

- (void)setSelectDate:(NSDate * _Nonnull)selectDate;
@end

NS_ASSUME_NONNULL_END
