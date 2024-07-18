//
//  putCarNumForRestrictVC.m
//  Onstar
//
//  Created by huyuming on 15/10/27.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "putCarNumForRestrictVC.h"
#import "Util.h"
#import "VehicleInfoUtil.h"

@interface putCarNumForRestrictVC ()

@end

@implementation putCarNumForRestrictVC

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.bgView.layer.cornerRadius = 30;
	self.bgView.layer.masksToBounds = YES;
	self.carNumImageV.layer.cornerRadius = 3;
	self.carNumImageV.layer.masksToBounds = YES;
	
	self.view.backgroundColor = [UIColor clearColor];
	_textCarNum.delegate = self;
	_textCarNum.text = UserDefaults_Get_Object(@"CarInfoTypeLicenseNum");
#pragma mark 收键盘
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
	customView.backgroundColor = [UIColor clearColor];
	_textCarNum.inputAccessoryView = customView;
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, -9, 35, 29)];
	[btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
	[customView addSubview:btn];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)CancelBackKeyboard:(id)sender     {
	[_textCarNum resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
	return;
//    if (textField == _textCarNum) {
//        if ([[Util trim:_textCarNum]length] < 1) {
//            [self text:NSLocalizedString(@"NullField", @"") Label:_labelTipCarNum forError:YES];
//            return;
//        }else{
//            
//        }
//        _labelTipCarNum.text = @"";
//    }
	
}

- (void)text:(NSString *)text Label:(UILabel *)label forError:(BOOL)error     {
	if (error) {
		label.textColor = [UIColor redColor];
	} else {
		label.textColor = [UIColor grayColor];
	}
	label.text = text;
	label.hidden = NO;
}

- (IBAction)sureAct:(UIButton *)sender {
	NSLog(@"校验车牌号");
	[_textCarNum resignFirstResponder];
	if ([[Util trim:_textCarNum]length] < 1) {
		[self text:NSLocalizedString(@"NullField", @"") Label:_labelTipCarNum forError:YES];
		return;
	} else {
		_textCarNum.text = [Util trim:_textCarNum];
		_textCarNum.text = _textCarNum.text.uppercaseString;
		BOOL isCorrectNum;
		isCorrectNum = [Util isCorrectLicenseNum:_textCarNum.text];
		if (!isCorrectNum) {
			[self text:@"该车牌号无效" Label:_labelTipCarNum forError:YES];
			return;
		} else {
			
		}
	}
	_labelTipCarNum.text = @"";
//    [self.reqRestrictDelegate toReqRestrict_carNum:_textCarNum.text];
    [VehicleInfoUtil updateVehicleLicensePlate:_textCarNum.text engine:UserDefaults_Get_Object(@"CarInfoTypeEngineNum") success:NULL failure:NULL];
}
@end
