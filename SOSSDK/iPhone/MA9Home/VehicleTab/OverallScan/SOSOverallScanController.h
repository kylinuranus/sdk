//
//  SOSOverallScanController.h
//  Onstar
//
//  Created by TaoLiang on 2019/3/29.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import "SOSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SOSOverallScanController;
@protocol SOSOverallScanDelegate <NSObject>
@optional
- (void)overallScanDidNotAuthorized:(__kindof SOSOverallScanController *)vc;
- (void)overallScanWillStartScan:(__kindof SOSOverallScanController *)vc;
- (void)overallScan:(__kindof SOSOverallScanController *)vc didFetchResults:(NSArray *)results;
- (void)overallScanDidEndScan:(__kindof SOSOverallScanController *)vc;

@end

@interface SOSOverallScanController : SOSBaseViewController

/**
 delegate,如果申明则不处理内部业务逻辑
 */
@property (weak, nonatomic) id<SOSOverallScanDelegate> delegate;

@property (weak, nonatomic) UIImageView *scanBGView;
@end

NS_ASSUME_NONNULL_END
