//
//  SOSBangcleKBTextField.m
//  Onstar
//
//  Created by Onstar on 2019/6/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSBangcleKBTextField.h"
static CGFloat spanDistance = 17.0f;

@implementation SOSBangcleKBTextField
- (CGRect)textRectForBounds:(CGRect)bounds
{
    bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance*2, bounds.size.height);
    if (self.rightView) {
        bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance - self.rightView.frame.size.width, bounds.size.height);
    }
    return bounds;
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    if (self.clearButtonMode != UITextFieldViewModeNever) {
        bounds = CGRectMake(spanDistance, 0, bounds.size.width - spanDistance*2 -30, bounds.size.height);
    }
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
- (void)setupPasswordField
{
//    [self setSecureTextEntry:YES];
    UIButton * rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"eye_click"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(passwordVisiable:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightView:rightButton];
    [self setRightViewMode:UITextFieldViewModeWhileEditing];
}
- (void)passwordVisiable:(id)sender
{
//    self.enabled = NO;
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    self.secureTextEntry = !self.secureTextEntry;
//    self.enabled = YES;
//    [self becomeFirstResponder];
}
- (void)addNormalBorderStyle{
    self.layer.masksToBounds=YES;
    self.layer.cornerRadius=4;
    self.layer.borderColor=[UIColor grayColor].CGColor;
    self.layer.borderWidth=0.5;
    
}
@end
