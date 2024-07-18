//
//  ChooseFingerView.m
//  Onstar
//
//  Created by Vicky on 16/2/19.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "ChooseFingerView.h"
#import "SOSBiometricsManager.h"
#import "AppPreferences.h"

#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH [UIScreen mainScreen].bounds.size.width-40
#define PWD_COUNT 6
#define DOT_WIDTH 10
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 100
#define ALERT_HEIGHT 280


@interface ChooseFingerView()
@property (nonatomic, strong) UIView *paymentAlert;
@property (nonatomic, strong) UILabel *titleLabel, *line,*line2,*line3;
@property (nonatomic, strong) UIButton *buttonFinger, *buttonPIN, *buttonCancel;
@property (nonatomic, strong) UIImageView *fingerView,*more1View,*more2View;
@property (nonatomic, strong) UILabel *labelOnstar;
@property (nonatomic, strong) UILabel *labelTouchID;
@property (nonatomic, strong) UILabel *labelPIN;
@end

@implementation ChooseFingerView

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
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, PAYMENT_WIDTH, TITLE_HEIGHT)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.text = NSLocalizedString(@"Onstar_PIN", nil);
        [_paymentAlert addSubview:_titleLabel];
        
        
        _line = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_HEIGHT+6, PAYMENT_WIDTH, .5f)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line];
        
        _fingerView = [[UIImageView alloc]initWithFrame:CGRectMake(15, TITLE_HEIGHT+15+25, 30, 30)];
        _fingerView.center = CGPointMake(_paymentAlert.frame.size.width/2,  TITLE_HEIGHT+15+11) ;
        NSString *imageName  = isSupportFaceId ? @"faceID" : @"finger_alert";
        [_fingerView setImage:[UIImage imageNamed:imageName]];
        [_paymentAlert addSubview:_fingerView];
        
        _buttonFinger = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonFinger setFrame:CGRectMake(0,TITLE_HEIGHT+40, PAYMENT_WIDTH, 64)];
        //        [_buttonFinger setBackgroundColor:[UIColor greenColor]];
        [_buttonFinger addTarget:self action:@selector(FingerTapped) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonPIN = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonPIN setFrame:CGRectMake(0,TITLE_HEIGHT+104, PAYMENT_WIDTH, 44)];
        //        [_buttonPIN setBackgroundColor:[UIColor yellowColor]];
        [_buttonPIN addTarget:self action:@selector(PINCodeTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [_paymentAlert addSubview:_buttonFinger];
        [_paymentAlert addSubview:_buttonPIN];
        
        
        _more1View = [[UIImageView alloc]initWithFrame:CGRectMake(PAYMENT_WIDTH-20, TITLE_HEIGHT+15+55, 7, 12.5)];
        [_more1View setImage:[UIImage imageNamed:@"image_more"]];
        [_paymentAlert addSubview:_more1View];
        
        _more2View = [[UIImageView alloc]initWithFrame:CGRectMake(PAYMENT_WIDTH-20, TITLE_HEIGHT+15+105, 7, 12.5)];
        [_more2View setImage:[UIImage imageNamed:@"image_more"]];
        [_paymentAlert addSubview:_more2View];
        
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
        NSString *labelTouchID = isSupportFaceId ? @"您还未设置面容 ID, 请点此设置" : @"您还未设置指纹密码，请点此设置";
        _labelTouchID.text = labelTouchID;
        [_paymentAlert addSubview:_labelTouchID];
        
        
        _labelPIN = [[UILabel alloc]initWithFrame:CGRectMake(10, TITLE_HEIGHT+15+11+30+20+41, _paymentAlert.size.width, 21)];
        _labelPIN.textAlignment = NSTextAlignmentLeft;
        _labelPIN.textColor = [UIColor grayColor];
        _labelPIN.font = [UIFont systemFontOfSize:14.0f];
        _labelPIN.text = NSLocalizedString(@"Finger_input", nil);
        [_paymentAlert addSubview:_labelPIN];
        
        _line2 = [[UILabel alloc]initWithFrame:CGRectMake(10, TITLE_HEIGHT+15+11+30+20+30, PAYMENT_WIDTH - 20, .5f)];
        _line2.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line2];
        
        _line3 = [[UILabel alloc]initWithFrame:CGRectMake(10, TITLE_HEIGHT+15+11+30+20+45+21+6, PAYMENT_WIDTH - 20, .5f)];
        _line3.backgroundColor = [UIColor lightGrayColor];
        [_paymentAlert addSubview:_line3];
        
        
        
        
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_buttonCancel.layer setMasksToBounds:YES];
        [_buttonCancel.layer setCornerRadius:5.0f];
        [_buttonCancel.layer setBorderWidth:1.0];
        [_buttonCancel.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor blueColor])];
        
        [_buttonCancel setFrame:CGRectMake(10.0,TITLE_HEIGHT + 15 +29+3+20+3+30+56+10, PAYMENT_WIDTH-20, 45)];
        [_buttonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_buttonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateSelected];
        [_buttonCancel setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        [_buttonCancel setTitleColor:[UIColor whiteColor]  forState:UIControlStateSelected];
        
        
        [_buttonCancel setBackgroundImage:[UIImage imageNamed:@"button_blue_long"] forState:UIControlStateNormal];
        [_buttonCancel addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_paymentAlert addSubview:_buttonCancel];
        
        _paymentAlert.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) ;
    }
    
}

- (void)show {
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;
    [keyWindow addSubview:self];
    
    _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    _paymentAlert.alpha = 0;
    
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{\
        _paymentAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        _paymentAlert.alpha = 1.0;
    } completion:nil];
}



- (void)dismiss{
    [UIView animateWithDuration:0.3f animations:^{
        _paymentAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
        _paymentAlert.alpha = 0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)FingerTapped{
    if (_openFingerView) {
        _openFingerView(YES);
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.3f];
    NSLog(@"complete");
}

- (void)PINCodeTapped{
    if (_openPINCodeView) {
        _openPINCodeView(YES);
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:.3f];
    NSLog(@"complete");
}
@end

