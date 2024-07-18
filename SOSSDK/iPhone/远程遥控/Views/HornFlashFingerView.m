//
//  HornFlashFingerView.m
//  Onstar
//
//  Created by Vicky on 16/2/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "HornFlashFingerView.h"
#import "UIButton+FillColor.h"
#import "SOSBiometricsManager.h"

#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH [UIScreen mainScreen].bounds.size.width-40
#define PWD_COUNT 6
#define DOT_WIDTH 10
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 100
#define ALERT_HEIGHT 260

@interface HornFlashFingerView (){
    BOOL isFlashSelected,isHornSelected;
}
@property (nonatomic, strong) UIView *paymentAlert;
@property (nonatomic, strong) UILabel *titleLabel, *line,*labelPIN;
@property (nonatomic, strong) UIButton *buttonPIN;
@property (nonatomic, strong) UIImageView *fingerView;
@property (nonatomic, strong) UILabel *labelOnstar;
@property (nonatomic, strong) UILabel *labelTouchID;
@property (nonatomic, strong) UIView *optionalView;
@property (nonatomic, strong) UIButton *buttonFlash,*buttonHorn;
@property (nonatomic, strong) UILabel *labelFlash,*labelHorn ;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *buttonCancel,*buttonOK;
@end

@implementation HornFlashFingerView


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
        BOOL isSupportFaceId = [SOSBiometricsManager isSupportFaceId];
        _paymentAlert = [[UIView alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height-KEYBOARD_HEIGHT-KEY_VIEW_DISTANCE-ALERT_HEIGHT, [UIScreen mainScreen].bounds.size.width-40, ALERT_HEIGHT)];
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
        NSString *titleLabel = isSupportFaceId ? @"面容 ID" : @"指纹密码";
        _titleLabel.text = titleLabel;
        [_paymentAlert addSubview:_titleLabel];
        
        
        
        _labelPIN = [[UILabel alloc]initWithFrame:CGRectMake(PAYMENT_WIDTH-80, 13, 80, 21)];
        _labelPIN.textAlignment = NSTextAlignmentCenter;
        _labelPIN.textColor = [UIColor colorWithHexString:@"1762cb"];
        _labelPIN.font = [UIFont systemFontOfSize:12];
        _labelPIN.text = NSLocalizedString(@"Onstar_PIN", nil);
        [_paymentAlert addSubview:_labelPIN];
        
        _buttonPIN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonPIN setFrame:CGRectMake(PAYMENT_WIDTH-80, 18, 80, 45)];
        [_buttonPIN addTarget:self action:@selector(buttonPINTapped) forControlEvents:UIControlEventTouchUpInside];
        [_paymentAlert addSubview:_buttonPIN];
        
        _line = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT+6, PAYMENT_WIDTH, .5f)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line];
        
        _fingerView = [[UIImageView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+15+25, 30, 30)];
        _fingerView.center = CGPointMake(_paymentAlert.frame.size.width/2,  TITLE_HEIGHT+15+11) ;
        NSString *imageName  = isSupportFaceId ? @"faceID" : @"finger_alert";
        [_fingerView setImage:[UIImage imageNamed:imageName]];
        [_paymentAlert addSubview:_fingerView];
        
        _labelOnstar = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT+15+11+30, _paymentAlert.size.width, 21)];
        _labelOnstar.textAlignment = NSTextAlignmentCenter;
        _labelOnstar.textColor = [UIColor blackColor];
        _labelOnstar.font = [UIFont systemFontOfSize:17.0f];
        NSString *labelOnstar = isSupportFaceId ? @"安吉星的面容 ID" : @"安吉星的Touch ID";
        _labelOnstar.text = labelOnstar;
        [_paymentAlert addSubview:_labelOnstar];
        
        _labelTouchID = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT+15+11+30+20, _paymentAlert.size.width, 21)];
        _labelTouchID.textAlignment = NSTextAlignmentCenter;
        _labelTouchID.textColor = [UIColor grayColor];
        _labelTouchID.font = [UIFont systemFontOfSize:14.0f];
        _labelTouchID.text = isSupportFaceId ? @"请验证已有面容 ID" : @"请验证已有指纹（Touch ID）";
        [_paymentAlert addSubview:_labelTouchID];
        
        
        
        _optionalView = [[UIView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT + 15 +29+3+20+3+30, PAYMENT_WIDTH-30, 30)];
        
        _buttonFlash = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonFlash setFrame:CGRectMake(40,3+5, 14, 14)];
        [_buttonFlash setImage:[UIImage imageNamed:@"checkbox_unselect"] forState:UIControlStateNormal];
        [_buttonFlash setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
        [_buttonFlash addTarget:self action:@selector(FlashSelected) forControlEvents:UIControlEventTouchUpInside];
        [_buttonFlash setSelected:YES];
        isFlashSelected = YES;
        
        _buttonHorn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonHorn setFrame:CGRectMake(_optionalView.center.x +5,3+5, 14, 14)];
        [_buttonHorn setImage:[UIImage imageNamed:@"checkbox_unselect"] forState:UIControlStateNormal];
        [_buttonHorn setImage:[UIImage imageNamed:@"checkbox_select"] forState:UIControlStateSelected];
        [_buttonHorn addTarget:self action:@selector(HornSelected) forControlEvents:UIControlEventTouchUpInside];
        [_buttonHorn setSelected:YES];
        isHornSelected = YES;
        
        _labelFlash = [[UILabel alloc]initWithFrame:CGRectMake(_buttonFlash.frame.origin.x +_buttonFlash.frame.size.width+5, 5, 50, 20)];
        _labelFlash.text = NSLocalizedString(@"PIN_flash", nil);
        _labelFlash.textColor = [UIColor colorWithHexString:@"0e1c2c"];
        
        _labelHorn = [[UILabel alloc]initWithFrame:CGRectMake(_buttonHorn.frame.origin.x +_buttonHorn.frame.size.width+5, 5, 50, 20)];
        _labelHorn.text = NSLocalizedString(@"PIN_horn", nil);
        _labelHorn.textColor = [UIColor colorWithHexString:@"0e1c2c"];
        
        
        [_optionalView addSubview:_buttonFlash];
        [_optionalView addSubview:_buttonHorn];
        [_optionalView addSubview:_labelFlash];
        [_optionalView addSubview:_labelHorn];
        
        _buttonView = [[UIView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT + 15 +29+3+20+3+30+36, PAYMENT_WIDTH-30, 45)];
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
        
        
        [_buttonOK setBackgroundImage:[UIImage imageNamed:@"button_blue_long"] forState:UIControlStateNormal];
        [_buttonOK addTarget:self action:@selector(buttonOKTapped) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:_buttonOK];
        
        _paymentAlert.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) ;
    }
    
}



- (void)FlashSelected{
    if (_buttonFlash.isSelected) {
        if(!_buttonHorn.selected){
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


- (void)HornSelected{
    if (_buttonHorn.isSelected) {
        if(!_buttonFlash.selected){
            [Util showAlertWithTitle:nil message:NSLocalizedString(@"hornOrLightMustChooseOne", @"") completeBlock:nil];
            return ;
        }
        [_buttonHorn setSelected:NO];
        isHornSelected = NO;
    }else{
        [_buttonHorn setSelected:YES];
        isHornSelected = YES;
    }
    
}

- (void)buttonOKTapped{
    
    if (_completeHandle) {
        _completeHandle(nil,isFlashSelected,isHornSelected);
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.3f];
    NSLog(@"complete");
    
    
}

- (void)show {
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
    [keyWindow addSubview:self];
    
    _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _paymentAlert.alpha = 0;
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentAlert.alpha = 1.0;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3f animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        _paymentAlert.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)buttonPINTapped {
    [self dismiss];
    if (_OpenPINView) {
        _OpenPINView(YES);
    }
}

- (void)setIsHornFlash:(BOOL)hornFlash {
    if (_isHornFlash != hornFlash) {
        _isHornFlash = hornFlash;
    }
    if (_isHornFlash) {
        [_paymentAlert addSubview:_optionalView];
    }
}

@end

