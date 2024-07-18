//
//  SOSTripFirstDealerVC.h
//  Onstar
//
//  Created by Coir on 2019/5/5.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum    {
    /// 加载中
    SOSTripFirstDealerStatus_Loading = 1,
    /// 加载成功
    SOSTripFirstDealerStatus_Success,
    /// 无数据
    SOSTripFirstDealerStatus_Empty,
    /// 数据加载失败
    SOSTripFirstDealerStatus_Fail
} SOSTripFirstDealerStatus;

@protocol SOSTripFirstDealerDelegate <NSObject>

- (void)firstDealerReloadButtonTapped;

@end

@interface SOSTripFirstDealerVC : UIViewController

@property (nonatomic, assign) BOOL fullScreenMode;
@property (nonatomic, strong) NNDealers *dealer;
@property (nonatomic, assign) SOSTripFirstDealerStatus status;
@property (nonatomic, weak) id <SOSTripFirstDealerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
