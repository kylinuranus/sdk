//
//  SOSTripAroundDealerVC.h
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSTripAroundDealerVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *dataTableView;

@property (nonatomic, copy) NSArray <NNDealers *>* dealerArray;
@property (nonatomic, strong) NSArray <NNDealers *>* recommendDealerArray;

/// 显示品牌选择 View
- (void)showBrandDataView:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
