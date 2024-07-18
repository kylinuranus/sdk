//
//  SOSCustomAlertView.m
//  SOSCustomAlertView
//
//  Created by Genie Sun on 2017/7/13.
//  Copyright © 2017年 Onstar. All rights reserved.
//

#import "SOSCustomAlertView.h"
#import "UIView+Utils.h"
#import "registerAlert.h"
#import "callAlert.h"
#import "SOSPhoneView.h"
#import "SOSAlertViewModelSendDownView.h"
#import "bindSuccess.h"
#import "updateOrUnBind.h"

@interface SOSCustomAlertView ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UIButton *completeBtn;
@property(nonatomic, strong) UIButton *otherButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *mainAlertView; //main alert view
@property(nonatomic, strong) NSArray *otherButtons;
@property (assign, nonatomic) BOOL canTapBackgroundHide;
@property (assign, nonatomic) BOOL isUpgradeFun;    //是否新功能升级的提示

@end

@implementation SOSCustomAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])     {
        self.isUpgradeFun = NO;
        self.radius = SDefaultAlertRadius;
        self.pageModel = SOSAlertViewModelContent;
        self.buttonMode = SOSAlertButtonModelVertical;
        self.backgroundModel = SOSAlertBackGroundModelStreak;
        [self registerKVC];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                   detailText:(NSString *)detailtext
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonsTitles {
    self = [self initWithTitle:title detailText:detailtext cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonsTitles canTapBackgroundHide:YES];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(NSString *)detailtext cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonsTitles canTapBackgroundHide:(BOOL)canTapBackgroundHide{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.title = title;
        self.detailText = detailtext;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonsTitles;
        self.canTapBackgroundHide = canTapBackgroundHide;
        [self configUI];
    }
    return self;
}

#pragma mark KVC
- (void)registerKVC {
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (void)unregisterKVC {
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"pageModel",@"buttonModel",@"backgroundModel", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    }
    else{
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keypath	{
    if ([keypath isEqualToString:@"pageModel"])	{
        [self updatePageModeStyle];
    }	else if ([keypath isEqualToString:@"backgroundModel"])	{
        [self updateBackgroundModeStyle];
    }    else if ([keypath isEqualToString:@"buttonModel"])    {
        
    }
}

#pragma mark - UI
- (void)configUI		{
    [self addSubview:self.maskView];
    [self addSubview:self.mainAlertView];
    [self.mainAlertView addSubview:self.titleLabel];
    [self.mainAlertView addSubview:self.infoLabel];
    [self updateBackgroundModeStyle];
    [self setupOtherButtons];
    if (_canTapBackgroundHide) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes)];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(empty)];
        [self addGestureRecognizer:tap];
        [self.mainAlertView addGestureRecognizer:tap1];

    }
}

- (void)setupOtherButtons		{
    if (self.completeBtn != nil) {
        [self.mainAlertView addSubview:self.completeBtn];
    }
    
    if (self.otherButtonTitles != nil) {
        NSMutableArray *tempButtonArray = [[NSMutableArray alloc] init];
        NSInteger i = 1;
        for (NSString *title in self.otherButtonTitles) {
            UIButton *otherButton = [UIButton buttonWithType:0];
            [otherButton setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
            [otherButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
            [otherButton setTitle:title forState:0];
            otherButton.tag = SButtonTag + i;
            [otherButton addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
            [tempButtonArray addObject:otherButton];
            [self.mainAlertView addSubview:otherButton];
            i++;
        }
        self.otherButtons = [tempButtonArray copy];
    }
}


- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setDetailText:(NSString *)detailText
{
    _detailText = detailText;
    self.infoLabel.text = detailText;
}

- (UIView *)mainAlertView {
    if (!_mainAlertView) {
        _mainAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SDefaultAlert_Width, SDefaultAlert_Height)];
        [_mainAlertView setCenter:self.center];
        [_mainAlertView.layer setCornerRadius:self.radius];
        _mainAlertView.layer.masksToBounds = YES;
        _mainAlertView.userInteractionEnabled = YES;
    }
    return _mainAlertView;
}

- (UIView *)maskView {
    if (!_maskView || !_maskView.superview) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _maskView.backgroundColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.18 alpha:0.6f];
        _maskView.alpha = 0.f;
        _maskView.userInteractionEnabled = YES;
    }
    return _maskView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"3A3A51"];
        _titleLabel.font = [UIFont systemFontOfSize:18.0];
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.textColor = [UIColor colorWithHexString:@"898994"];
        _infoLabel.font = [UIFont systemFontOfSize:13.f];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (UIButton *)completeBtn {
    if (!_completeBtn) {
        _completeBtn = [UIButton buttonWithType:0];
        [_completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_completeBtn setBackgroundColor:[UIColor colorWithHexString:@"107FE0"] forState:0];
        [_completeBtn setTitle:self.cancelButtonTitle forState:0];
        [_completeBtn.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        _completeBtn.tag = SButtonTag;
        [_completeBtn addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}

- (UIButton *)otherButton	{
    if (!_otherButton) {
        _otherButton = [UIButton buttonWithType:0];
        [_otherButton setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
        [_otherButton.titleLabel setFont:[UIFont systemFontOfSize:17.f]];
        [_otherButton addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherButton;
}

#pragma mark - layout
- (void)layoutSubviews  {
    [super layoutSubviews];
    
    //titleLabel frame
    [self.titleLabel setFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainAlertView.frame), 0)];
    [self.titleLabel sizeToFit];
    CGPoint titleCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, 20+CGRectGetHeight(self.titleLabel.frame)/2 );
    [self.titleLabel setCenter:titleCenter];
    
    //infoLabel
    [self.infoLabel setFrame:CGRectMake(10, 0, CGRectGetWidth(self.mainAlertView.frame) - 20, 0)];
    [self.infoLabel sizeToFit];
    
    CGPoint detailCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, 10+CGRectGetHeight(self.infoLabel.frame)/2 + CGRectGetMaxY(self.titleLabel.frame));
    [self.infoLabel setCenter:detailCenter];
    
    if (self.customView) {
        [self.customView setFrame:CGRectMake(self.customView.frame.origin.x, self.infoLabel.frame.origin.y+self.infoLabel.frame.size.height, self.customView.width, self.customView.height)];
    }
    
    //一个按钮
    if (self.cancelButtonTitle != nil && self.otherButtonTitles == nil){
        CGRect buttonFrame = CGRectMake(0, 0, SDefaultAlert_Width, SDefaultButton_Height);
        [self.completeBtn setFrame:buttonFrame];
        [SOSUtilConfig setView:self.completeBtn RoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeMake(SDefaultAlertRadius, SDefaultAlertRadius)];
        CGPoint buttonCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, self.mainAlertView.height - 25);
        [self.completeBtn setCenter:buttonCenter];
    }
    
    // 多个按钮
    [self updateButtonFrame];
    
    //目前没用上
    if (self.cancelButtonTitle == nil && [self.otherButtonTitles count] == 1) {
        UIButton *rightButton = (UIButton *)self.otherButtons[0];
        CGRect buttonFrame = CGRectMake(0, 0, SDefaultAlert_Width , SDefaultButton_Height);
        [rightButton setFrame:buttonFrame];
        
        CGPoint buttonCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, SDefaultAlert_Height - 25);
        [rightButton setCenter:buttonCenter];
    }
}

- (void)setupOtherButtonsHorizotalFrame        {
    if (self.cancelButtonTitle != nil && [self.otherButtonTitles count] == 1) {
//        CGRect buttonFrame = CGRectMake(0, 0, (SDefaultAlert_Width)/2 - 1, SDefaultButton_Height);
//        [self.completeBtn setFrame:buttonFrame];
//
//        CGPoint leftButtonCenter = CGPointMake(CGRectGetWidth(self.completeBtn.frame)/2 , SDefaultAlert_Height - 20);
//        [self.completeBtn setCenter:leftButtonCenter];
        
        self.completeBtn.frame = CGRectMake(0, SDefaultAlert_Height - SDefaultButton_Height, (SDefaultAlert_Width) / 2 - 0.5, SDefaultButton_Height);
        
        UIButton *rightButton = (UIButton *)self.otherButtons[0];
//        [rightButton setFrame:buttonFrame];
//
//        CGPoint rightButtonCenter = CGPointMake(SDefaultAlert_Width - CGRectGetWidth(rightButton.frame)/2 , SDefaultAlert_Height  - 20);
//        [rightButton setCenter:rightButtonCenter];
        
        rightButton.frame = CGRectMake((SDefaultAlert_Width) / 2 + 0.5, SDefaultAlert_Height - SDefaultButton_Height, (SDefaultAlert_Width) / 2, SDefaultButton_Height);
    }
}

- (void)setupOtherButtonsVerticalFrame         {
    if (self.cancelButtonTitle != nil && [self.otherButtonTitles count] >= 1) {
        
        CGRect buttonFrame = CGRectMake(0, 0, SDefaultAlert_Width, SDefaultButton_Height);
        
        for (NSInteger i = 0; i < self.otherButtons.count ;  i++) {
            UIButton *button = (UIButton *)self.otherButtons[i];
            [button setFrame:buttonFrame];
            
            CGPoint pointCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height *(self.otherButtons.count-i) - 19.f);
            [button setCenter:pointCenter];
            UIView *viewLine = [UIView new];
            viewLine.frame = CGRectMake(0, 0, SDefaultAlert_Width, 1.f);
            viewLine.backgroundColor = [UIColor colorWithHexString:@"F1F1F1"];
            [button addSubview:viewLine];
        }
        
        [self.completeBtn setFrame:CGRectMake(0, self.mainAlertView.height - SDefaultButton_Height, SDefaultAlert_Width, SDefaultButton_Height)];
        [SOSUtilConfig setView:self.completeBtn RoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight withRadius:CGSizeMake(SDefaultAlertRadius, SDefaultAlertRadius)];

//        CGPoint leftButtonCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2 , CGRectGetHeight(self.mainAlertView.frame) - CGRectGetHeight(self.infoLabel.frame) + 36);
//        [self.completeBtn setCenter:leftButtonCenter];
        
        //adjust
        if ((SDefaultButton_Height * (self.otherButtons.count + 1) + CGRectGetMaxY(self.infoLabel.frame))>CGRectGetHeight(self.mainAlertView.frame)) {
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = SDefaultButton_Height * (self.otherButtons.count + 1) + CGRectGetMaxY(self.infoLabel.frame);
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
        }
       
    }
}

#pragma mark - model style
- (void)updateBackgroundModeStyle		{
    switch (self.backgroundModel) {
        case SOSAlertBackGroundModelStreak:{
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_header_bg"]];
            imageView.tag = 1088;
            [_mainAlertView addSubview:imageView];
            [_mainAlertView setBackgroundColor:[UIColor whiteColor]];
        }
            break;
        case SOSAlertBackGroundModelWhite:
            for (UIImageView *view in _mainAlertView.subviews) {
                if ([view isKindOfClass:[UIImageView class]] && view.tag == 1088) {
                    [view removeFromSuperview];
                }
            }
            [_mainAlertView setBackgroundColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
}

- (void)updatePageModeStyle	{
    switch (self.pageModel) {
        case SOSAlertViewModelCallPhone:	{
            callAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"callAlert" owner:self options:nil][0];
            self.customView = alert;
            if (self.phoneFunctionID) {
                alert.functionID = self.phoneFunctionID;
            }
            if (self.phoneCallDetailText) {
                alert.detailLabel.text = self.phoneCallDetailText;
            }
            [alert setFrame:CGRectMake(0, 0, self.mainAlertView.width, alert.height)];
            self.mainAlertView.height = self.mainAlertView.height+self.customView.height + SDefaultButton_Height*self.otherButtonTitles.count;
            [self.mainAlertView setCenter:self.center];
            [self.mainAlertView addSubview:alert];
            [self setNeedsLayout];
        }
            break;
        case SOSAlertViewModelCallPhoneOnlyPhone:    {
            callAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"callAlert" owner:self options:nil][0];
            alert.detailLabel.text = nil;
            self.customView = alert;
            if (self.phoneFunctionID) {
                alert.functionID = self.phoneFunctionID;
            }
            if (self.phoneCallDetailText) {
                alert.detailLabel.text = self.phoneCallDetailText;
            }
            [alert setFrame:CGRectMake(0, 0, self.mainAlertView.width, alert.height)];
            self.mainAlertView.height = self.mainAlertView.height+self.customView.height + SDefaultButton_Height*self.otherButtonTitles.count;
            [self.mainAlertView setCenter:self.center];
            [self.mainAlertView addSubview:alert];
            [self setNeedsLayout];
        }
            break;
        case SOSAlertViewModelCallPhone_Icon:		{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 300;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];

            SOSPhoneView *alert = [[NSBundle SOSBundle] loadNibNamed:@"SOSPhoneView" owner:self options:nil][0];
            alert.frame = CGRectMake(0, 80, SDefaultAlert_Width, CGRectGetHeight(alert.frame));
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelTitleAndIcon :{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 200;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            SOSPhoneView *alert = [[NSBundle SOSBundle] loadNibNamed:@"SOSPhoneView" owner:self options:nil][0];
            alert.iconImageView.image = [UIImage imageNamed:self.iconImageName];
            alert.frame = CGRectMake(0, 60, SDefaultAlert_Width, 60);
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelRemovedStatement:
            
            break;
        case SOSAlertViewModelVehicleSurvey:
            
            break;
        case SOSAlertViewModelSendDown:		{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 300;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            SOSAlertViewModelSendDownView *alert = [[NSBundle SOSBundle] loadNibNamed:@"SOSAlertViewModelSendDownView" owner:self options:nil][0];
            alert.frame = CGRectMake(0, 80, SDefaultAlert_Width, CGRectGetHeight(alert.frame));
            alert.tag = 99;
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelRegister:		{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 350;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            registerAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"registerAlert" owner:self options:nil][0];
            if (self.phoneFunctionID) {
                alert.functionID = self.phoneFunctionID;
            }
            alert.infoLb.text = NSLocalizedString(@"Register_Success_Wait", nil);
            alert.frame = CGRectMake(0, 80, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 80);
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelNotification:		 {
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 350;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            registerAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"registerAlert" owner:self options:nil][0];
            NSAssert(self.notificationDetailText.isNotBlank, @"notificationDetailText不能为空");
            alert.infoLb.text = self.notificationDetailText;
            alert.infoImage.image = [UIImage imageNamed:@"套餐_icon_car_4G_colour"];
            alert.frame = CGRectMake(0, 80, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 80);
            [self.mainAlertView addSubview:alert];
        }
            break;
            
        case SOSAlertViewModelRegisterFail:		{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 350;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            registerAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"registerAlert" owner:self options:nil][0];
            if (self.phoneFunctionID) {
                alert.functionID = self.phoneFunctionID;
            }
            alert.infoLb.text = NSLocalizedString(@"Register_Fail_Wait", nil);
            alert.infoImage.image = [UIImage imageNamed:@"icon_warnning_yellow"];
            alert.frame = CGRectMake(0, 80, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 80);
            [self.mainAlertView addSubview:alert];
        }
            break;
//        case SOSAlertViewModelCallPhoneMusic:    {
//            callAlert *alert = [[NSBundle SOSBundle] loadNibNamed:@"callAlert" owner:self options:nil][0];
//            alert.detailLabel.text = @"使用车内蓝键或拨打客服电话订购";
//            self.customView = alert;
//            if (self.phoneFunctionID) {
//                alert.functionID = self.phoneFunctionID;
//            }
//            if (self.phoneCallDetailText) {
//                alert.detailLabel.text = self.phoneCallDetailText;
//            }
//            [alert setFrame:CGRectMake(0, 0, self.mainAlertView.width, alert.height)];
//            self.mainAlertView.height = self.mainAlertView.height+self.customView.height + SDefaultButton_Height*self.otherButtonTitles.count;
//            [self.mainAlertView setCenter:self.center];
//            [self.mainAlertView addSubview:alert];
//            [self setNeedsLayout];
//        }
//            break;
        case SOSAlertViewModelMirrorBindSuccess:        {
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 290;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            bindSuccess *alert = [[NSBundle SOSBundle] loadNibNamed:@"bindSuccess" owner:self options:nil][0];
            alert.frame = CGRectMake(0, 60, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 80);
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelMirrorUnbindSuccess:        {
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 190;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            updateOrUnBind *alert = [[NSBundle SOSBundle] loadNibNamed:@"updateOrUnBind" owner:self options:nil][0];
            //alert.lb_tishi.text = @"您需要重启后视镜或唤醒后视镜后说";
            alert.frame = CGRectMake(0, 60, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 100);
            [self.mainAlertView addSubview:alert];
        }
            break;

        case SOSAlertViewModelMirrorUpdate:        {
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 190;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];
            [self setNeedsLayout];
            
            updateOrUnBind *alert = [[NSBundle SOSBundle] loadNibNamed:@"updateOrUnBind" owner:self options:nil][0];
            //alert.lb_tishi.text = @"您需要唤醒后视镜后说";
            alert.frame = CGRectMake(0, 60, SDefaultAlert_Width, CGRectGetHeight(self.mainAlertView.frame) - SDefaultButton_Height - 80);
            [self.mainAlertView addSubview:alert];
        }
            break;
        case SOSAlertViewModelUpgrade:{
            self.maskView.backgroundColor = [UIColor blackColor];
            self.isUpgradeFun = YES;
        }
            break;
            
        case SOSAlertViewModelNavSendDown:{
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 400;
            self.mainAlertView.frame = frame;
            CGPoint pointMainAlert = CGPointMake(CGRectGetWidth(self.frame)/2 , CGRectGetHeight(self.frame)/2);
            [self.mainAlertView setCenter:pointMainAlert];

            
            UILabel *lb = [[UILabel alloc] init];
            lb.text = @"正在下发导航到后视镜\n请耐心等候1～3分钟";
            lb.font = [UIFont systemFontOfSize:18];
            lb.textAlignment = NSTextAlignmentCenter;
            lb.numberOfLines = 0;
            [self.mainAlertView addSubview:lb];
            
            [lb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mainAlertView.mas_top).offset(20);
                make.left.equalTo(self.mainAlertView.mas_left).offset(20);
                make.right.equalTo(self.mainAlertView.mas_right).offset(-20);
                make.height.mas_equalTo(50);
            }];
            
            UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loading_passion_blue_idle"]];
            view.tag = 99;
            [self.mainAlertView addSubview:view];
            
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mainAlertView.mas_centerX);
                make.centerY.equalTo(self.mainAlertView.mas_centerY);
                make.width.height.mas_equalTo(100);
                make.height.mas_equalTo(75);
            }];
        }
            break;

        default:
            break;
    }
}


- (void)updateButtonFrame		{
    switch (self.buttonMode) {
        case SOSAlertButtonModelVertical:
            [self.otherButtons[0] setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
            [self.otherButtons[0] setBackgroundColor:[UIColor clearColor]];
            [self setupOtherButtonsVerticalFrame];
            break;
        case SOSAlertButtonModelHorizontal:
            [self.otherButtons[0] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.otherButtons[0] setBackgroundColor:[UIColor colorWithHexString:@"107FE0"]];
            [self setupOtherButtonsHorizotalFrame];
            break;
        default:
            break;
    }
}


#pragma mark - alert action
- (void)show	{
    UIWindow *keyWindow = SOS_ONSTAR_WINDOW;

    [keyWindow addSubview:self.maskView];
    [keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:0.25 animations:^{
        self.maskView.alpha = self.isUpgradeFun ? 0.8f : 1.f;
        self.alpha = 1.f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        self.isUpgradeFun = NO;
    }];
}

- (void)empty 	{
}

- (void)tapGes{
    [self hide];
    if (self.tapGesDismissHandle)		self.tapGesDismissHandle();
}

- (void)hide	{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.f;
        self.maskView.alpha = 0.f;
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    }completion:^(BOOL finished) {
        if (finished) {
            [_maskView removeFromSuperview];
            _maskView = nil;
            [self removeFromSuperview];
        }
    }];
}

- (void)buttonTouch:(UIButton *)button {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hide];
    });
   
    if (_buttonClickHandle) {
        _buttonClickHandle(button.tag - SButtonTag);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sosAlertView:didClickButtonAtIndex:)]) {
        [self.delegate sosAlertView:self didClickButtonAtIndex:button.tag - SButtonTag];
    }
}


- (void)dealloc {
    [self unregisterKVC];
}


@end


