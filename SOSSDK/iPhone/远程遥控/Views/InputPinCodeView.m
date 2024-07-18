//
//  DCPaymentView.m
//  DCPayAlertDemo
//
//  Created by dawnnnnn on 15/12/9.
//  Copyright © 2015年 dawnnnnn. All rights reserved.
//

#import "InputPinCodeView.h"
#import "UIButton+FillColor.h"
#import "Util.h"
#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH [UIScreen mainScreen].bounds.size.width-40
#define PWD_COUNT 6
#define DOT_WIDTH 10
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 100
#define ALERT_HEIGHT 260


@interface InputPinCodeView ()<UITextFieldDelegate>     {
    BOOL isFlashSelected,isHornSelected;
}
@property (nonatomic, strong) UIView *paymentAlert;
@property (nonatomic, strong) UILabel *titleLabel, *line;

@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIButton *buttonEye;
@property (nonatomic, strong) UILabel *lineShort;

@property (nonatomic, strong) UIView *telView;
@property (nonatomic, strong) UILabel *labelTel;

@property (nonatomic, strong) UIView *optionalView;
@property (nonatomic, strong) UIButton *buttonFlash,*buttonHorn;
@property (nonatomic, strong) UILabel *labelFlash,*labelHorn ;

@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *buttonCancel, *buttonOK;

@property (nonatomic, strong) UILabel  *detailLabel, *amountLabel;


@end

@implementation InputPinCodeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
        
        [self drawView];
    }
    return self;
}

- (void)drawView {
    if (!_paymentAlert) {
        _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-KEYBOARD_HEIGHT-KEY_VIEW_DISTANCE-ALERT_HEIGHT, [UIScreen mainScreen].bounds.size.width-40, ALERT_HEIGHT)];
        if ([Util isDeviceiPhone5]) {
            _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-KEYBOARD_HEIGHT-KEY_VIEW_DISTANCE-ALERT_HEIGHT+70, [UIScreen mainScreen].bounds.size.width-40, ALERT_HEIGHT)];
        }else if([Util isDeviceiPhone4]){
            _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-KEYBOARD_HEIGHT-KEY_VIEW_DISTANCE-ALERT_HEIGHT+120, [UIScreen mainScreen].bounds.size.width-40, ALERT_HEIGHT)];
        }
        _paymentAlert.layer.cornerRadius = 5.f;
        _paymentAlert.layer.masksToBounds = YES;
        _paymentAlert.backgroundColor = [UIColor colorWithWhite:1. alpha:.95];
        [self addSubview:_paymentAlert];
        
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonCancel setFrame:CGRectMake(10,2, 45, 45)];
        [_buttonCancel setImage:[UIImage imageNamed:@"button_close"] forState:UIControlStateNormal];
        [_buttonCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_paymentAlert addSubview:_buttonCancel];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, PAYMENT_WIDTH, TITLE_HEIGHT)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.text = NSLocalizedString(@"Onstar_PIN", nil);
        [_paymentAlert addSubview:_titleLabel];
        
        _line = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT+6, PAYMENT_WIDTH, .5f)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line];
        
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+15+11, PAYMENT_WIDTH-30, 29)];
        [_inputView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"新密码"]]];
        
        _buttonEye = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonEye setFrame:CGRectMake(_inputView.frame.size.width -30,2, 22, 13)];
        [_buttonEye setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
        [_buttonEye setImage:[UIImage imageNamed:@"eye_click"] forState:UIControlStateSelected];
        [_buttonEye addTarget:self action:@selector(showWord) forControlEvents:UIControlEventTouchUpInside];
        
        _pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, -6, _inputView.frame.size.width -60 , 29)];
        _pwdTextField.delegate = self;
        _pwdTextField.keyboardType = UIKeyboardTypeDefault;
        _pwdTextField.placeholder = NSLocalizedString(@"Onstar_PIN", nil);
        _pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwdTextField.secureTextEntry = YES;
        [_inputView addSubview:_pwdTextField];
        [_inputView addSubview:_buttonEye];
        
        [_paymentAlert addSubview:_inputView];
        
        _labelTel = [[UILabel alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+57, PAYMENT_WIDTH-30, 20)];
        _labelTel.textAlignment = NSTextAlignmentLeft;
        
        _labelTel.attributedText = [self AttributeString:NSLocalizedString(@"Onstar_Contact_Number", nil) andRearNumber:12];
        [_paymentAlert addSubview:_labelTel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(makeCall)];
        _labelTel.userInteractionEnabled = YES;
        [_labelTel addGestureRecognizer:tap];
        
        _optionalView = [[UIView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT + 90, PAYMENT_WIDTH-30, 30)];
        
        _buttonFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonFlash setFrame:CGRectMake(40,8, 14, 14)];
        [_buttonFlash setImage:[UIImage imageNamed:@"checkbox_unselect"] forState:UIControlStateNormal];
        [_buttonFlash setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
        [_buttonFlash addTarget:self action:@selector(FlashSelected) forControlEvents:UIControlEventTouchUpInside];
        [_buttonFlash setSelected:YES];
        isFlashSelected = YES;
        
        _buttonHorn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonHorn setFrame:CGRectMake(_optionalView.center.x +5,8, 14, 14)];
        [_buttonHorn setImage:[UIImage imageNamed:@"checkbox_unselect"] forState:UIControlStateNormal];
        [_buttonHorn setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
        [_buttonHorn addTarget:self action:@selector(HornSelected) forControlEvents:UIControlEventTouchUpInside];
        [_buttonHorn setSelected:YES];
        isHornSelected = YES;
        
        _labelFlash = [[UILabel alloc]initWithFrame:CGRectMake(_buttonFlash.frame.origin.x +_buttonFlash.frame.size.width+5, 5, 50, 20)];
        _labelFlash.text = NSLocalizedString(@"PIN_flash", nil);
        _labelFlash.textColor = [UIColor colorWithHexString:@"0e1c2c" ];
        
        _labelHorn = [[UILabel alloc]initWithFrame:CGRectMake(_buttonHorn.frame.origin.x +_buttonHorn.frame.size.width+5, 5, 50, 20)];
        _labelHorn.text = NSLocalizedString(@"PIN_horn", nil);
        _labelHorn.textColor = [UIColor colorWithHexString:@"0e1c2c"];
        
        
        [_optionalView addSubview:_buttonFlash];
        [_optionalView addSubview:_buttonHorn];
        [_optionalView addSubview:_labelFlash];
        [_optionalView addSubview:_labelHorn];
        
        _buttonView = [[UIView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+136, PAYMENT_WIDTH-30, 45)];
        [_paymentAlert addSubview:_buttonView];
        
        _buttonOK = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_buttonOK.layer setMasksToBounds:YES];
        [_buttonOK.layer setCornerRadius:5.0f];
        [_buttonOK.layer setBorderWidth:1.0];
        [_buttonOK.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor blueColor])];

        [_buttonOK setFrame:CGRectMake(10.0,0, PAYMENT_WIDTH-50, 45)];
        [_buttonOK setTitle:NSLocalizedString(@"pincodeButtonOkTitle", nil) forState:UIControlStateNormal];
        [_buttonOK setTitle:NSLocalizedString(@"pincodeButtonOkTitle", nil) forState:UIControlStateSelected];
        [_buttonOK setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        [_buttonOK setTitleColor:[UIColor whiteColor]  forState:UIControlStateSelected];
        
        [_buttonOK setBackgroundColor:[UIColor colorWithRGB:0x1762cb] forState:UIControlStateNormal];
        [_buttonOK setBackgroundColor:[UIColor colorWithRGB:0x1762cb alpha:0.5] forState:UIControlStateDisabled];
        
        [_buttonOK addTarget:self action:@selector(buttonOKTapped) forControlEvents:UIControlEventTouchUpInside];
         _buttonOK.enabled = NO;
        [_buttonView addSubview:_buttonOK];
        
   }
    
}

- (void)makeCall{
    [self contactOnstar];

}

- (void)contactOnstar     {
        [SOSUtil callPhoneNumber:CONTACT_ONSTART_NUMBER];
}

- (void)showWord{
    _buttonEye.selected = !_buttonEye.selected;
    if (_buttonEye.isSelected) {
        _pwdTextField.secureTextEntry = NO;
        NSString* text = _pwdTextField.text;
        _pwdTextField.text = @" ";
        _pwdTextField.text = text;
    }else{
        _pwdTextField.secureTextEntry = YES;
        NSString* text = _pwdTextField.text;
        _pwdTextField.text = @" ";
        _pwdTextField.text = text;
    }
    
}


- (void)FlashSelected	{
    if (_buttonFlash.isSelected) {
        if(!_buttonHorn.selected)	{
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") completeBlock:nil];
            return ;
        }
        [_buttonFlash setSelected:NO];
        isFlashSelected = NO;
    }else{
        [_buttonFlash setSelected:YES];
        isFlashSelected = YES;
    }
    
}


- (void)HornSelected	{
    if (_buttonHorn.isSelected) {
        if(!_buttonFlash.selected)	{
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") completeBlock:nil];
            return ;
        }
        isHornSelected = NO;
        [_buttonHorn setSelected:NO];
        
    }else{
        isHornSelected = YES;
        [_buttonHorn setSelected:YES];
        
    }
    
}

- (void)buttonOKTapped	{
    if ([[Util trimWhite:_pwdTextField] length] < 6) {
        _buttonOK.enabled = NO;
    }
    else {
        _buttonOK.enabled = YES;
        if (_completeHandle) {
            _completeHandle([Util trimWhite:_pwdTextField],isFlashSelected,isHornSelected);
        }
        
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.3f];
        NSLog(@"complete");
        
    }
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _paymentAlert.alpha = 0;

    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentAlert.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_pwdTextField becomeFirstResponder];
        });
    }];
}

- (void)dismiss {
    [_pwdTextField resignFirstResponder];
    [UIView animateWithDuration:0.3f animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        _paymentAlert.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (_cancelPIN) {
            _cancelPIN();
        }
        if (self) {
            [self removeFromSuperview];
        }
    }];
}


#pragma mark - 

#pragma mark -设置lable
- (NSMutableAttributedString *)AttributeString:(NSString *)str andRearNumber:(int)rear {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    int bigSize =12;
    int smallSize =12;
    
    //数值 98%
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:bigSize] range:NSMakeRange(0, str.length - rear)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, str.length - rear)];
    //单位：%；km；kpa
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:smallSize] range:NSMakeRange(str.length - rear,  rear)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(str.length - rear,  rear)];
    return attributedString;
    
}


- (void)setIsHornFlash:(BOOL)hornFlash {
    if (_isHornFlash != hornFlash) {
        _isHornFlash = hornFlash;
    }
    if (_isHornFlash) {
        [_paymentAlert addSubview:_optionalView];
    }else{
        [_buttonView setFrame:CGRectMake(_buttonView.frame.origin.x, _buttonView.frame.origin.y -46, _buttonView.frame.size.width, _buttonView.frame.size.height)];
        [_paymentAlert setFrame:CGRectMake(_paymentAlert.frame.origin.x, _paymentAlert.frame.origin.y, _paymentAlert.frame.size.width, _paymentAlert.frame.size.height -46)];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *newValue = [_pwdTextField.text mutableCopy];
    [newValue replaceCharactersInRange:range withString:string];
    if ([newValue length]< 6) {
        _buttonOK.enabled = NO;
    }
    else {
        _buttonOK.enabled = YES;
        
    }
    
    return YES;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self buttonOKTapped];
    return YES;
}
@end
