//
//  SOSHeadInfoView.h
//  Onstar
//
//  Created by Genie Sun on 2017/9/6.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSBaseXibView.h"

@interface SOSHeadInfoView : SOSBaseXibView
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *infoLb;

@end
