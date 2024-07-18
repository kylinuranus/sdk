//
//  SOSRegisterAgreementView.h
//  Onstar
//
//  Created by TaoLiang on 02/05/2018.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSAgreementEntranceBaseView.h"

@interface SOSRegisterAgreementView : SOSAgreementEntranceBaseView

@property (assign, nonatomic) BOOL isAllSelected;

@property (copy, nonatomic) void (^checkState)(BOOL allSelected);


@end
