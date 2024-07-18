//
//  SOSTripDealerContainerVC.h
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseSegmentViewController.h"
#import "SOSTripAroundDealerVC.h"
#import "SOSTripFirstDealerVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripDealerContainerVC : SOSBaseSegmentViewController

@property (nonatomic, assign) BOOL fullScreenMode;
@property (nonatomic, copy) NSArray <NNDealers *>* dealerArray;
@property (nonatomic, strong) NSArray <NNDealers *>* recommendDealerArray;

@property (nonatomic, strong) SOSTripFirstDealerVC *firstDealerVC;

@property (nonatomic, strong) SOSTripAroundDealerVC *aroundDealerVC;

- (void)configSelf;

@end

NS_ASSUME_NONNULL_END
