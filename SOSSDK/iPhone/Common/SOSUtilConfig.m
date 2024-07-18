    //
//  SOSUtilConfig.m
//  Onstar
//
//  Created by Genie Sun on 2017/7/25.
//  Copyright © 2017年 Shanghai Onstar. All rights reserved.
//

#import "SOSUtilConfig.h"
#import <QuartzCore/QuartzCore.h>

#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation SOSUtilConfig

+ (void) setView:(UIView *)viewCorner RoundingCorners:(UIRectCorner)corners withRadius:(CGSize)cornerRadii
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:viewCorner.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = viewCorner.bounds;
    maskLayer.path = maskPath.CGPath;
    viewCorner.layer.mask = maskLayer;
}

+ (NSMutableAttributedString *) setLabelAttributedText:(NSString*)attribute AttachmentWithView:(UIImage *)image ImageOffset:(CGRect)imgRect withImagePosition:(POSITION)position    {
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:attribute];
    
    NSTextAttachment *attch = [[NSTextAttachment alloc] init];
    if (image) {
        attch.image = image;
    }
    NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attch];
    switch (position) {
        case LEFT_POSITION:
            attch.bounds = CGRectMake(imgRect.origin.x, imgRect.origin.y, image.size.width, image.size.height);
            [attrText insertAttributedString:imageStr atIndex:0];
            break;
        case RIGHT_POSITION:
            attch.bounds = CGRectMake(imgRect.origin.x, imgRect.origin.y, image.size.width, image.size.height);
            [attrText insertAttributedString:imageStr atIndex:attrText.length];
            break;
        default:
            break;
    }
    return attrText;
    
}

+ (NSMutableAttributedString *) setLabelAttributedText:(NSString*)attribute AttachmentWithView:(UIImage *)image withImagePosition:(POSITION)position
{
    NSMutableAttributedString *attrText;
    switch (position) {
        case LEFT_POSITION:
            attrText = [SOSUtilConfig setLabelAttributedText:attribute AttachmentWithView:image ImageOffset:CGRectMake(0, - 5, image.size.width, image.size.height) withImagePosition:position];
            break;
        case RIGHT_POSITION:
            attrText = [SOSUtilConfig setLabelAttributedText:attribute AttachmentWithView:image ImageOffset:CGRectMake(0, - 10, image.size.width, image.size.height) withImagePosition:position];
            break;
        default:
            attrText = [SOSUtilConfig setLabelAttributedText:attribute AttachmentWithView:image ImageOffset:CGRectNull withImagePosition:position];
            break;
    }
    return attrText;
}


+ (void) transformRotationWithView:(UIImageView *)imageView {
    [self transformIdentityStatusWithView:imageView];
    CABasicAnimation *appDeleteShakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    appDeleteShakeAnimation.repeatDuration = HUGE_VALF;
    appDeleteShakeAnimation.duration = 1;
    appDeleteShakeAnimation.cumulative = YES; // 旋转累加角度
    appDeleteShakeAnimation.toValue=[NSNumber numberWithFloat:2 * M_PI];
    appDeleteShakeAnimation.removedOnCompletion = NO;
    appDeleteShakeAnimation.fillMode = kCAFillModeForwards;
    [imageView.layer addAnimation:appDeleteShakeAnimation forKey:@"appDeleteShakeAnimation"];

}

+ (void)transformIdentityStatusWithView:(UIImageView *)imageView {
    imageView.layer.transform = CATransform3DIdentity;
    [imageView.layer removeAnimationForKey:@"appDeleteShakeAnimation"];
}

+ (void)rotateView:(UIView *)view {
    if (!view) {
        return;
    }
    [self stopRotateAndHideView:view];
    view.hidden = NO;
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.repeatDuration = HUGE_VALF;
    rotateAnimation.duration = 1;
    rotateAnimation.cumulative = YES; // 旋转累加角度
    rotateAnimation.toValue=[NSNumber numberWithFloat:2 * M_PI];
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:rotateAnimation forKey:@"rotate"];
}

+ (void)stopRotateAndHideView:(UIView *)view {
    if (!view) {
        return;
    }
    view.hidden = YES;
    view.layer.transform = CATransform3DIdentity;
    [view.layer removeAnimationForKey:@"rotate"];
}

+ (void)setNavigationBarItemTitle:(NSString *)title target:(id)target selector:(SEL)action {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
    menuButton.tintColor = [UIColor colorWithHexString:@"107FE0"];
    [target navigationItem].rightBarButtonItem = menuButton;
    [[target navigationItem].rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"PingFangSC-Regular" size:16.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
}

+ (void) setCancelBackKeyBoardWithTextField:(UITextField *)tf target:(id)tar    {
    // 自定义的view
    UIView * customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    customView.backgroundColor = [UIColor clearColor];
    // 往自定义view中添加各种UI控件(以UIButton为例)
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(customView.frame.size.width-35, 0, 35, 29)];
    [btn setImage:[UIImage imageNamed:@"down_normal.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"down_highlight.png"] forState:UIControlStateSelected];
    [btn addTarget:tar action:@selector(CancelBackKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    tf.inputAccessoryView = customView;
}

+ (UIImage *)returnImageBySortOfCarbrand
{
    if ([Util vehicleIsBuick]) {
        return [UIImage imageNamed:@"brand_BUICK"];
    }else if ([Util vehicleIsCadillac])
    {
        return [UIImage imageNamed:@"brand_CADILLAC"];
    }else if ([Util vehicleIsChevrolet])
    {
        return [UIImage imageNamed:@"brand_CHEVROLET"];
    }
    return [UIImage imageNamed:@"icon_placeholder_Empty"];
}

@end
