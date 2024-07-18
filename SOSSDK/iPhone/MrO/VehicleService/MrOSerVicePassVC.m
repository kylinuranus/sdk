//
//  MrOSerVicePassVC.m
//  Onstar
//
//  Created by huyuming on 15/10/22.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "MrOSerVicePassVC.h"
#import "AppPreferences.h"
 
#import "CustomerInfo.h"



@interface MrOSerVicePassVC ()

@end

@implementation MrOSerVicePassVC
@synthesize pinCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"确定   viewDidLoad");
    _passBgImageV.layer.cornerRadius = 3;
    _passBgImageV.layer.masksToBounds = YES;
    
 
    
#pragma mark 收键盘
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    customView.backgroundColor = [UIColor clearColor];
    _servicePassTF.inputAccessoryView = customView;
    // 往自定义view中添加各种UI控件(以UIButton为例)
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, -9, 35, 29)];
    [btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    
    _servicePassTF.delegate = self;
}

- (void)CancelBackKeyboard:(id)sender     {
    [_servicePassTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}





- (IBAction)sureAct:(id)sender {
    NSLog(@"确定");
    NSString *pinCodeEx = @"[A-Za-z0-9.-]{1,}";
    NSPredicate *pinCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pinCodeEx];
    
    if ([pinCodeTest evaluateWithObject:[_servicePassTF text]] != YES)
    {
        _passErrorLB.text = @"服务密码错误，请重新输入";
        _passErrorLB.hidden = NO;
        return;
    }
    
    _passErrorLB.hidden = YES;
    [_servicePassTF resignFirstResponder];
    NSString *resultCode = [[LoginManage sharedInstance] upgradeToken:_servicePassTF.text];
    if ([resultCode isEqual:@"0"]) {
        //Success
        [self.pinCodeDelegate checkPinCodeToExcutive];
    } else {
	    _passErrorLB.text = @"服务密码错误，请重新输入";
	    _passErrorLB.hidden = NO;
	    _servicePassTF.text = @"";
    }

//	[self.pinCodeDelegate checkPinCodeToExcutive];
}




- (void)textFieldDidBeginEditing:(UITextField *)textField     {
    _passErrorLB.hidden = YES;
}
@end
