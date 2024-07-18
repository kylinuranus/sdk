//
//  SOSInfoFlowSettingCell.h
//  Onstar
//
//  Created by TaoLiang on 2019/1/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface SOSInfoFlowSettingCell : UITableViewCell
@property (strong, nonatomic) SOSInfoFlowSetting *setting;

@property (copy, nonatomic) void (^trigger)(BOOL isOn);

@end

NS_ASSUME_NONNULL_END
