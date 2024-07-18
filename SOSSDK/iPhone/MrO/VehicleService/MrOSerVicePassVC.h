//
//  MrOSerVicePassVC.h
//  Onstar
//
//  Created by huyuming on 15/10/22.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol checkPinCodeToExcutiveDelegate <NSObject>

//服务密码验证通过后执行车辆命令
- (void)checkPinCodeToExcutive;

@end




@interface MrOSerVicePassVC : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

@property (strong, nonatomic) IBOutlet UILabel *titleServiceLB;

@property (strong, nonatomic) IBOutlet UITextField *servicePassTF;

@property (strong, nonatomic) IBOutlet UIImageView *passBgImageV;

@property (strong, nonatomic) IBOutlet UILabel *passErrorLB;

@property (strong, nonatomic)NSString *pinCode;

- (IBAction)sureAct:(id)sender;

@property (nonatomic, weak) id<checkPinCodeToExcutiveDelegate> pinCodeDelegate;

@end
