//
//  SOSAgreementAlertView.h
//  Onstar
//
//  Created by TaoLiang on 20/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSAgreement.h"

typedef NS_ENUM(NSUInteger, SOSAgreementAlertViewStyle) {
    SOSAgreementAlertViewStyleLogin,
    SOSAgreementAlertViewStyleSignUp,
    SOSAgreementAlertViewStyleRVM
};

@interface SOSAgreementAlertView : UIView
@property (strong, nonatomic) NSArray<SOSAgreement *> *agreements;

@property (readonly, assign, nonatomic) SOSAgreementAlertViewStyle alertStyle;


@property (copy, nonatomic) void (^agree)(void);
@property (copy, nonatomic) void (^disagree)(void);

- (instancetype)initWithAlertViewStyle:(SOSAgreementAlertViewStyle)alertStyle;



/**
 直接在keyWindow显示
 */
- (void)show;

/**
 根据传入的View显示，原因是因为landingViewController会占用keyWindow的rootViewController，此时若要显示，会显示在landingView上，等自动切换回主页就出问题了

 @param parentView <#parentView description#>
 */
- (void)showInView:(__kindof UIView *)parentView;
- (void)hide;

@end
