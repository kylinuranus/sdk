//
//  SOSBleKeyView.h
//  Onstar
//
//  Created by onstar on 2018/7/19.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSBleKeyView : UIView
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel *vinLabel;
@property (weak, nonatomic) IBOutlet UIButton *reConnectButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

//@property (nonatomic, copy) void(^operationBlock)(UIButton *button);
- (void)changeStartStatus;
@end
