//
//  SOSRegisterTextField.m
//  Onstar
//
//  Created by lizhipan on 2017/8/16.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSRegisterTextField.h"
static CGFloat spanDistance = 17.0f;
@interface accessoryView : UIView

@end
@implementation accessoryView

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    UIView *sub = [self viewWithTag:1001];
    if (sub) {
        if (CGRectContainsPoint(sub.frame, point)) {
            return YES;
        }
        else{
            return NO;
        }
    }
    return NO;
}
@end

@implementation SOSRegisterTextField

- (instancetype)init    {
    self = [super init];
    if (self) {
//        [self addTextInputPredicate];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder    {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addCustomAccessoryView];
//        [self addTextInputPredicate];
        [self setTextColor:[SOSUtil onstarTextFontColor]];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self addCustomAccessoryView];
//        [self addTextInputPredicate];
        [self setTextColor:[SOSUtil onstarTextFontColor]];
    }
    return self;
}

- (void)addCustomAccessoryView   {
    // 自定义的键盘上部accessoryView
    accessoryView * customAccessoryView = [[accessoryView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    customAccessoryView.backgroundColor = [UIColor clearColor];
    // 往自定义view中添加各种UI控件(以UIButton为例)
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customAccessoryView.frame.size.width-35, 0, 35, 30)];
    [btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 1001;
    [customAccessoryView addSubview:btn];
    //        self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputAccessoryView = customAccessoryView;
}
- (void)addNormalBorderStyle{
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius=4;
    self.layer.borderColor=[UIColor grayColor].CGColor;
    self.layer.borderWidth=0.5;

}
- (void)addTextInputPredicate   {
    [self.rac_textSignal subscribeNext:^(NSString *x) {
        
        NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d\\s]*$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        BOOL isMatch = [pred evaluateWithObject:x];
        if (!isMatch){
            self.text = [x regularChar];
        }
       
    }];
}


- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance, bounds.size.height);
    if (self.rightView) {
     bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance - self.rightView.frame.size.width, bounds.size.height);
    }
    return bounds;
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance, bounds.size.height);
    if (self.rightView) {
        bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance - self.rightView.frame.size.width, bounds.size.height);
    }
    return bounds;
}
- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance, bounds.size.height);
    if (self.rightView) {
        bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance - self.rightView.frame.size.width, bounds.size.height);
    }
    return bounds;
}
- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect clearRect = [super clearButtonRectForBounds:bounds];

    clearRect = CGRectMake(clearRect.origin.x - spanDistance, clearRect.origin.y, clearRect.size.width , clearRect.size.height);
    return clearRect;
}
- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    rightRect.origin.x = self.frame.size.width - rightRect.size.width - spanDistance;
    return rightRect;
}
- (void)setupVerifyCodeRightViewWithDelegate:(id)del Method:(SEL)sel
{
    UIButton * right = [UIButton buttonWithType:UIButtonTypeCustom];
    [right setFrame:CGRectMake(0, 0, 110, 25)];
    [right setBackgroundImage:[UIImage imageNamed:@"btn_getcode_timer"] forState:UIControlStateNormal];
    [right.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size:12.0f]];
    [right setTitle:@"获取验证码" forState:UIControlStateNormal];
    [right setTitleColor:[UIColor colorWithHexString:@"107FE0"] forState:UIControlStateNormal];
    [right addTarget:del action:sel forControlEvents:UIControlEventTouchUpInside];
    [self setRightView:right];
    [self setRightViewMode:UITextFieldViewModeAlways];
}
- (void)setupPasswordField
{
    [self setSecureTextEntry:YES];
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"eye_click"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(passwordVisiable:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightView:rightButton];
    [self setRightViewMode:UITextFieldViewModeWhileEditing];
}
- (void)setupScanButtonWithDelegate:(id)del responseMethod:(SEL)sel
{
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setImage:[UIImage imageNamed:@"xiangji"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"eye_click"] forState:UIControlStateSelected];
    [rightButton addTarget:del action:sel forControlEvents:UIControlEventTouchUpInside];
    [self setRightView:rightButton];
    [self setRightViewMode:UITextFieldViewModeAlways];
}
- (void)passwordVisiable:(id)sender
{
    self.enabled = NO;
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    self.secureTextEntry = !self.secureTextEntry;
    self.enabled = YES;
    [self becomeFirstResponder];
}
- (void)CancelBackKeyboard:(id)sender
{
    [self resignFirstResponder];
}
- (void)setupDropdownComboboxDelegate:(id)del Method:(SEL)sel
{
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setImage:[UIImage imageNamed:@"icon_arrow_down_passion_blue_idle"] forState:UIControlStateNormal];
    [rightButton addTarget:del action:sel forControlEvents:UIControlEventTouchUpInside];
    [self setRightView:rightButton];
    [self setRightViewMode:UITextFieldViewModeAlways];
}
- (void)clearRightView
{
    self.rightView = nil;
}
@end
@implementation SOSRegisterAddressTextField


@end

