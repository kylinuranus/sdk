//
//  SOSMeCustomerServiceCell.h
//  Onstar
//
//  Created by Onstar on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSCardBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSMeCustomerServiceCell : SOSCardBaseCell
@property (nonatomic,assign,setter=sos_setIsCustomerService:)BOOL isCustomerService;

@end

NS_ASSUME_NONNULL_END
