//
//  SOSchangePhmailNumber.h
//  Onstar
//
//  Created by Genie Sun on 2017/3/23.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    changephoneNb = 0,
    changemailNb,
} pageType;

@interface SOSchangePhmailNumber : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *tipLb;
@property(nonatomic, assign) pageType pagetype;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableheight;
@property(nonatomic, strong) NSString *info;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property(nonatomic, strong) NSString *oldInfo;
@property(nonatomic, strong) NNNotifyConfig *notObject;
@end
