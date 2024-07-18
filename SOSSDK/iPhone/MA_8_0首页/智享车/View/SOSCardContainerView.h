//
//  SOSCardContainerView.h
//  Onstar
//
//  Created by lmd on 2017/9/21.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSCardContainerView : UIView

@property (weak, nonatomic) IBOutlet UIView *configCellView;
@property (weak, nonatomic) IBOutlet UIImageView *iconSign;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *infoLb;
@property (weak, nonatomic) IBOutlet UIImageView *transformView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowView;
@property(nonatomic, assign) RemoteControlStatus status;

@end
