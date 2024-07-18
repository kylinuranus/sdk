//
//  ViewControllerInputCarNum.m
//  Onstar
//
//  Created by Vicky on 15/5/26.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "ViewControllerInputCarNum.h"
#import "CarNumInputView.h"
#import "VehicleInfoUtil.h"
#import "Util.h"
#import "UserCarInfoVC.h"
@interface ViewControllerInputCarNum () <CarNumInputViewDelegate, UITextFieldDelegate>   {
    CarNumInputView *inputView;
    __weak IBOutlet UIButton *provinceButton;
}

@end

@implementation ViewControllerInputCarNum

- (void)viewDidLoad {
	[super viewDidLoad];
    
    inputView = [[CarNumInputView alloc] init];
    inputView.delegate = self;
    [SOS_ONSTAR_WINDOW addSubview:inputView];
	
	self.bgView.layer.cornerRadius = 30;
	self.bgView.layer.masksToBounds = YES;
	self.view.backgroundColor = [UIColor clearColor];
	
	self.carNumImageV.layer.cornerRadius = 3.0;
	self.carNumImageV.layer.masksToBounds = YES;
	
	self.engineImageV.layer.cornerRadius = 3.0;
	self.engineImageV.layer.masksToBounds = YES;
    
    provinceButton.layer.cornerRadius = provinceButton.height / 2;
    provinceButton.layer.masksToBounds = YES;
    provinceButton.layer.borderColor = provinceButton.titleLabel.textColor.CGColor;
    provinceButton.layer.borderWidth = .4;
	
	
	_textCarNum.delegate = self;
	_textEngine.delegate = self;
	
	
	NSString *carNum = UserDefaults_Get_Object(@"CarInfoTypeLicenseNum");
	NSString *engine = UserDefaults_Get_Object(@"CarInfoTypeEngineNum");
    if (carNum.length) {
        NSString *provinceStr = [carNum substringToIndex:1];
        NSString *numberStr = [carNum substringFromIndex:1];
        [provinceButton setTitle:provinceStr forState:UIControlStateNormal];
        if (carNum) {
            _textCarNum.text = numberStr;
        }
        if (engine) {
            _textEngine.text = engine;
        }
    }
	
#pragma mark 收键盘
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
	customView.backgroundColor = [UIColor clearColor];
	_textEngine.inputAccessoryView = customView;
	_textCarNum.inputAccessoryView = customView;
	// 往自定义view中添加各种UI控件(以UIButton为例)
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, -9, 35, 29)];
	[btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
	[customView addSubview:btn];
}

- (void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    [self beginEditProvince];
}

- (void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];
    [self beginEditProvince];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)CancelBackKeyboard:(id)sender     {
	[_textCarNum resignFirstResponder];
	[_textEngine resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField.tag == 0 ) {
		[_textEngine becomeFirstResponder];
	}
	if(textField.tag == 1 ) {
	}
	
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string    {
    if (textField == _textEngine) {
        if (range.length == 0) {
            textField.text = [textField.text stringByAppendingString:[string uppercaseString]];
            return NO;
        }
        return YES;
    }

    if (range.length == 0) {
        textField.text = [textField.text stringByAppendingString:[string uppercaseString]];
        if(textField.text.length>7)
        {
            textField.text = [textField.text substringToIndex:7];
        }
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField     {
    [self endEditProvince];
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

- (IBAction)buttonSubmitTapped:(UIButton *)sender {
	NSLog(@"提交车牌号");
	[_textCarNum resignFirstResponder];
	[_textEngine resignFirstResponder];
	if ([[Util trim:_textCarNum]length] < 1) {
		[self text:NSLocalizedString(@"NullField", @"") Label:_labelTipCarNum forError:YES];
		return;
	}else{


		_textCarNum.text = [Util trim:_textCarNum];
		_textCarNum.text = _textCarNum.text.uppercaseString;
        _carNumString = [provinceButton.titleLabel.text stringByAppendingString:_textCarNum.text];
		BOOL isCorrectNum;
		isCorrectNum = [Util isCorrectLicenseNum:_carNumString];
		if (!isCorrectNum) {
			[self text:@"该车牌号无效" Label:_labelTipCarNum forError:YES];
			return;
		} else {
			
		}
	}
	_labelTipCarNum.text = @"";
	if ([[Util trim:_textEngine]length] < 1) {
		[self text:NSLocalizedString(@"NullField", @"") Label:_labelTipEngine forError:YES];
		return;
	}else{
		_textEngine.text = [Util trim:_textEngine];
		_textEngine.text = _textEngine.text.uppercaseString;
		BOOL isCorrectNum = [Util isCorrectEngineNum:_textEngine.text];
		if (!isCorrectNum) {
			[self text:@"该发动机号无效" Label:_labelTipEngine forError:YES];
			return;
		} else {
		}
	}
	_labelTipEngine.text = @"";
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.reqViolationDelegate toRequestViolationList_carNum:_carNumString engineNum:_textEngine.text];
	});
	
    [Util showLoadingView];
    [VehicleInfoUtil updateVehicleLicensePlate:_carNumString engine:_textEngine.text success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
        });
        
    } failure:^(NSString *resp_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Util hideLoadView];
        });
    }];
}

- (IBAction)selectProvince:(UIButton *)sender {
    [_textCarNum resignFirstResponder];
    [_textEngine resignFirstResponder];
    [self beginEditProvince];
}

- (void)beginEditProvince   {
    [UIView animateWithDuration:.5 animations:^{
        inputView.bottom = SCREEN_HEIGHT;
    }];
}

- (void)endEditProvince     {
    [UIView animateWithDuration:.5 animations:^{
        inputView.top = SCREEN_HEIGHT;
    }];
}

#pragma mark - CarNumInputView Delegate
- (void)outputStrChanged:(NSString *)output     {
    provinceButton.titleLabel.text = output;
    [provinceButton setTitle:output forState:UIControlStateNormal];
}

- (void)finishInput     {
    [self endEditProvince];
    [_textCarNum becomeFirstResponder];
}

- (void)dealloc     {
    [inputView removeFromSuperview];
}

- (void)viewDidUnload {
	[self setTextCarNum:nil];
	[self setTextEngine:nil];
	[self setLabelTipCarNum:nil];
	[self setLabelTipEngine:nil];
	[super viewDidUnload];
}

@end
