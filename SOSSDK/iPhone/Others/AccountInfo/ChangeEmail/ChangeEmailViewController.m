//
//  ChangeEmailViewController.m
//  Onstar
//
//  Created by Vicky on 14-2-24.
//  Copyright (c) 2014年 Shanghai Onstar. All rights reserved.
//

#import "ChangeEmailViewController.h"
#import "CustomerInfo.h"
#import "LoadingView.h"
#import "NSString+JWT.h"
#import "AccountInfoUtil.h"

@interface ChangeEmailViewController () {
	NSTimer *timer;
	BOOL isSendCheckOK;
	NSTimer *timerCheckCode;
    BOOL isExist;
}
@end

@implementation ChangeEmailViewController
@synthesize  oldEmail;

- (void)viewDidLoad     {
	[super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
	// Do any additional setup after loading the view from its nib.isPop = NO;
    isExist = NO;
    buttonOK.layer.masksToBounds = YES;
    buttonOK.layer.cornerRadius = 3;
    labelOld.text = NSLocalizedString(@"SB022-06", nil);
    labelOld.textColor = [UIColor blackColor];
    self.tipLb.text = NSLocalizedString(@"updated_Mobile_Email", nil);
    self.tipLb.adjustsFontSizeToFitWidth = YES;
    
	isSendCheckOK = YES;
	if(![oldEmail isEqualToString:@""])
	{
        labelOld.hidden = NO;
		fieldOld.text = oldEmail;
		labelOldEmail.text = [oldEmail stringEmailInterceptionHide];//[Util replaceStringWithStar:oldEmail];
		fieldOld.userInteractionEnabled = NO;
        _hidenoemail.hidden = NO;
	}else
	{
		fieldOld.hidden = YES;
		labelOld.hidden = YES;
		labelOldEmail.hidden = YES;
        _hidenoemail.hidden = YES;
		[self isHiddenOldResetView];
	}
	
    if (IS_IPHONE_5 | IS_IPHONE_4_OR_LESS) {
        scroll.contentSize = CGSizeMake(SCREEN_WIDTH, 440);
    }
	scroll.type = TPKeyboardAvoidingScrollViewTypeAdjust;
	scroll.scrollEnabled = YES;
	// Do any additional setup after loading the view from its nib.
	labelTitle.text = NSLocalizedString(@"changeEmail", nil);
	labelNew.text = NSLocalizedString(@"SB022-07", nil);
	labelSendCheck.text = NSLocalizedString(@"RecieveCheck", nil);
	labelOk.text = NSLocalizedString(@"changeSave", nil);
	labelTitle.adjustsFontSizeToFitWidth = YES;
	labelOld.adjustsFontSizeToFitWidth = YES;
	labelNew.adjustsFontSizeToFitWidth = YES;
	labelSendCheck.adjustsFontSizeToFitWidth = YES;
	labelOk.adjustsFontSizeToFitWidth = YES;
	labelMsg.adjustsFontSizeToFitWidth = YES;
	labelTipNew.adjustsFontSizeToFitWidth = YES;
	labelTipCode.adjustsFontSizeToFitWidth = YES;
	
	fieldNew.clearButtonMode = UITextFieldViewModeWhileEditing;
	fieldNew.returnKeyType = UIReturnKeyNext;
	fieldNew.delegate = self;
	fieldNew.placeholder = NSLocalizedString(@"PlsNewEmail", nil);
	
	fieldCheckCode.clearButtonMode = UITextFieldViewModeWhileEditing;
	fieldCheckCode.returnKeyType = UIReturnKeyDone;
	fieldCheckCode.delegate = self;
	fieldCheckCode.placeholder = NSLocalizedString(@"inPutCaptchaImage", nil);
	
	// hidden keybord
	UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
	customView.backgroundColor = [UIColor clearColor];
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-50, -5, 50, 30)];
	[btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
	[btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
	[btn addTarget:self action:@selector(cancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
	[customView addSubview:btn];
	
	fieldNew.inputAccessoryView = customView;
	fieldCheckCode.inputAccessoryView = customView;
	fieldCheckCode.keyboardType = UIKeyboardTypeNumberPad;
	
}


- (void)cancelBackKeyboard:(id)sender     {
	[fieldNew resignFirstResponder];
	[fieldCheckCode resignFirstResponder];
}

- (void)timerFireMethod:(NSTimer *)theTimer     {
	timer =theTimer;
	NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
	NSDateComponents *endTime = [[NSDateComponents alloc] init];    //初始化目标时间...
	NSDate *today = [NSDate date];    //得到当前时间
	
	NSDate *date = [NSDate dateWithTimeInterval:60 sinceDate:today];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateString = [dateFormatter stringFromDate:date];
	
	static int year;
	static int month;
	static int day;
	static int hour;
	static int minute;
	static int second;
	if(timeStart) {//从NSDate中取出年月日，时分秒，但是只能取一次
		year = [[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
		month = [[dateString substringWithRange:NSMakeRange(5, 2)] intValue];
		day = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
		hour = [[dateString substringWithRange:NSMakeRange(11, 2)] intValue];
		minute = [[dateString substringWithRange:NSMakeRange(14, 2)] intValue];
		second = [[dateString substringWithRange:NSMakeRange(17, 2)] intValue];
		timeStart= NO;
	}
	
	[endTime setYear:year];
	[endTime setMonth:month];
	[endTime setDay:day];
	[endTime setHour:hour];
	[endTime setMinute:minute];
	[endTime setSecond:second];
	NSDate *todate = [cal dateFromComponents:endTime]; //把目标时间装载入date
	
	//用来得到具体的时差，是为了统一成北京时间   2016-1-4验证码
	unsigned int unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour | NSCalendarUnitMinute| NSCalendarUnitSecond;
	NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:todate options:0];
	NSString *fen = [NSString stringWithFormat:@"%ld", (long)[d minute]];
	if([d minute] < 10) {
		fen = [NSString stringWithFormat:@"0%ld",(long)[d minute]];
	}
	NSString *miao = [NSString stringWithFormat:@"%ld", (long)[d second]];
	if([d second] < 10) {
		miao = [NSString stringWithFormat:@"0%ld",(long)[d second]];
	}
	
	if([d second] > 0) {
        labelSendCheck.text = [NSString stringWithFormat:@"%@(%ld)",NSLocalizedString(@"Resend", nil),(long)[d second]];
		fieldNew.enabled = NO;
		buttonSendCheck.enabled = NO;
		buttonSendCheck.userInteractionEnabled = NO;
		//计时尚未结束，do_something
		
	} else if([d second] == 0) {
		fieldNew.enabled = NO;
		labelSendCheck.text = NSLocalizedString(@"Resend", nil);
		//计时1分钟结束，do_something
		buttonSendCheck.enabled = YES;
		buttonSendCheck.userInteractionEnabled = YES;
		
	} else{
		[theTimer invalidate];
		[timerCheckCode invalidate];
		timerCheckCode = Nil;
	}
}

- (IBAction)backButtonTapped:(id)sender {
	if (timerCheckCode) {
		[timerCheckCode invalidate];
		timerCheckCode = nil;
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSendCheckTapped:(id)sender {
	if ([[Util trim:fieldNew] length] < 1) {
		
		labelTipNew.text =NSLocalizedString(@"NullField", @"");
		isSendCheckOK = NO;
		return;
		
	}else{
		bool showAlert =[Util isValidateEmail:[Util trim:fieldNew]];
		if(!showAlert)
		{
			labelTipNew.text = NSLocalizedString(@"SB022_MSG007", @"");
			isSendCheckOK = NO;
			return;
		}
		labelTipNew.text =@"";
		isSendCheckOK = YES;
		if(isSendCheckOK)
		{
			action = checkCode;
			/*
			 timeStart = YES;
			 if (timerCheckCode) {
			 [timerCheckCode invalidate];
			 timerCheckCode = Nil;
			 }
			 timerCheckCode = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
			 */
			[self sendValidationCode];
			
		}
	}
}

- (IBAction)buttonOKTapped:(id)sender {
    ////[[SOSReportService shareInstance] recordActionWithFunctionID:REPORT_ConfirmModifyEmail];

	[self.view endEditing:YES];
	if ([[Util trim:fieldNew] length] < 1) {
		
		labelTipNew.text =NSLocalizedString(@"NullField", @"");
		isSendCheckOK = NO;
		return;
		
	}else{
		bool showAlert =[Util isValidateEmail:[Util trim:fieldNew]];
		if(!showAlert)
		{
			labelTipNew.text = NSLocalizedString(@"SB022_MSG007", @"");
			isSendCheckOK = NO;
			return;
        }
        if(![oldEmail isEqualToString:@""]){
            if([[Util trim:fieldNew] isEqualToString:oldEmail]){
                labelTipNew.text = NSLocalizedString(@"mobile_same", @"");
                isSendCheckOK = NO;
                return;
            }
        }
	}
	
	labelTipNew.text =@"";
	if([[Util trim:fieldCheckCode]length]<1)
	{
		labelTipCode.text = NSLocalizedString(@"NullField", nil);
		return;
		
	}else
	{
		labelTipCode.text =@"";
		action = checkAgree;
		[self updateEmail];
		
	}
}

- (void)sendValidationCode{
    NSString *newEmail = [Util trim:fieldNew];
    [AccountInfoUtil getmobileEmailVerifyCode:newEmail Success:^(NNRegisterResponse *response) {
        BOOL isEmailUnique = [response.isEmailUnique boolValue];
        if(isEmailUnique)
        {
            labelTipNew.text = @"";
            timeStart = YES;
            if (timerCheckCode) {
                [timerCheckCode invalidate];
                timerCheckCode = Nil;
            }
            timerCheckCode = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
            
            if ([[SOSLanguage getCurrentLanguage] isEqualToString:LANGUAGE_ENGLISH])
            {
                labelMsg.text =[ NSString stringWithFormat:@"%@ %@",@"Already send dynamic code to your email",[Util trim:fieldNew ] ];
            }else{
                labelMsg.text =[ NSString stringWithFormat:@"%@%@%@",@"已经向您的邮箱",[Util trim:fieldNew ],@"发送验证码" ];
            }
            isExist = NO;
            
        }else
        {
            isExist = YES;
            //邮箱已经存在
            labelTipNew.text = NSLocalizedString(@"SB022_MSG002", nil);
        }

    } Failed:^{
        
    }];
}

- (void)updateEmail{
    NSString *newEmail = [Util trim:fieldNew];
    NSString *validateCode = [Util trim:fieldCheckCode];
    [AccountInfoUtil updateMobileEmail:newEmail ValidateCode:validateCode Success:^(NNRegisterResponse *response) {
        NSString *desc = response.desc;
        [Util showAlertWithTitle:nil message:desc completeBlock:^(NSInteger buttonIndex) {
            [CustomerInfo sharedInstance].changeEmailNo = [Util trim:fieldNew];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } Failed:^{
        
    }];
}


#pragma mark - UITextFieldDelegate delegate
#pragma mark - textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField.tag == 999 )
	{
		[fieldCheckCode becomeFirstResponder];
	}
	if(textField.tag == 1002 )
	{
		[self buttonOKTapped:nil];
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField     {
	[scroll adjustOffsetToIdealIfNeeded];
}

- (void)textFieldDidEndEditing:(UITextField *)textField     {
	
	if (textField == fieldNew) {
		if ([[Util trim:fieldNew] length] < 1) {
			
			labelTipNew.text =NSLocalizedString(@"NullField", @"");
			isSendCheckOK = NO;
			return;
			
		}else{
			bool showAlert =[Util isValidateEmail:[Util trim:fieldNew]];
			if(!showAlert)
			{
				labelTipNew.text = NSLocalizedString(@"SB022_MSG007", @"");
				isSendCheckOK = NO;
				return;
			}
			
		}
        if (isExist) {
            
        }else{
            labelTipNew.text =@"";
            isSendCheckOK = YES;
        }
		
	}
	else if (textField == fieldCheckCode)
	{
		if ([[Util trim:fieldCheckCode] length] < 1) {
			
			labelTipCode.text =NSLocalizedString(@"NullField", @"");
			return;
			
		}
		labelTipCode.text = @"";
	}
	
	else{
		[textField resignFirstResponder];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string     {
	if (range.location >= 30)
		return NO; // return NO to not change text
	return YES;
}

- (void)isHiddenOldResetView     {
    CGRect upToViewFrame = self.upToView.frame;
    upToViewFrame.origin.y -= TO_UP_ORIGNY;
    self.upToView.frame = upToViewFrame;
    
    CGRect buttonOKFrame = buttonOK.frame;
    buttonOKFrame.origin.y -= TO_UP_ORIGNY;
    buttonOK.frame = buttonOKFrame;

    CGRect labelOkFrame = labelOk.frame;
    labelOkFrame.origin.y -= TO_UP_ORIGNY;
    labelOk.frame = labelOkFrame;

    CGRect tipLbFrame = self.tipLb.frame;
    tipLbFrame.origin.y -= TO_UP_ORIGNY;
    self.tipLb.frame = tipLbFrame;
}

@end
