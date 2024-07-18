//
//  SOSAlertRemindSet.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/17.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSAlertRemindSet : UIView

@property(nonatomic, strong) UIView *maskView;

- (void)showShareReportView;
- (void)dismissShareReportView;
@end
