//
//  SOSAgreementAlertTopView.h
//  Onstar
//
//  Created by TaoLiang on 24/04/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSAgreement.h"

@interface SOSAgreementAlertTopView : UIView
@property (strong, nonatomic) NSArray<SOSAgreement *> *agreements;
@property (readonly, strong, nonatomic) NSArray<__kindof UIButton *> *buttons;
@property (assign, nonatomic) NSUInteger selectIndex;

@property(copy, nonatomic) void (^select)(NSUInteger index);

@end
