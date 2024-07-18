//
//  SOSAgreementEntranceBaseView.h
//  Onstar
//
//  Created by TaoLiang on 14/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+DetectLink.h"
#import "SOSAgreement.h"

@interface SOSAgreementEntranceBaseView : UIView

@property (strong, nonatomic) NSMutableArray<SOSAgreement *> *agreements;

@property (copy, nonatomic) void (^tapAgreement)(NSInteger line, NSInteger index);

@property (copy, nonatomic) void (^tapAgreement2)(NSInteger line, SOSAgreement *model);

- (NSArray<NSValue *> *)getRangesForAgreement:(NSString *)agreement;
@end
