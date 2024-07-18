//
//  SOSTripDealerVC.h
//  Onstar
//
//  Created by Coir on 2019/4/30.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSTripBaseMapVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripDealerVC : SOSTripBaseMapVC

@property (nonatomic, assign) BOOL fullScreenMode;
@property (nonatomic, copy) NSMutableArray <NNDealers *>* dealerArray;
@property (nonatomic, copy) NNDealers *selectedDealer;

@end

NS_ASSUME_NONNULL_END
