//
//  SOSTrailCardView.h
//  Onstar
//
//  Created by Coir on 2019/10/9.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSTripCardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOSTrailCardView : UIView

/// 卡片状态
@property (nonatomic, assign) SOSTripCardStatus cardStatus;

@property (nonatomic, strong) SOSTrailResp *data;

@property (nonatomic, weak) id<SOSTripCardDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
