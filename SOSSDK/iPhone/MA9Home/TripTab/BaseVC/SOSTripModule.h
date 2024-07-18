//
//  SOSTrioModule.h
//  Onstar
//
//  Created by Onstar on 2018/11/17.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import "SOSTripHomeVC.h"
#import <Objection/Objection.h>
#import "SOSBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripModule : SOSBaseModule

+ (BOOL)shouldShowCardWithCardType:(int)cardType;

+ (SOSTripHomeVC *)getMainTripVC;
+ (void)refreshFootPrint;
@end

NS_ASSUME_NONNULL_END
