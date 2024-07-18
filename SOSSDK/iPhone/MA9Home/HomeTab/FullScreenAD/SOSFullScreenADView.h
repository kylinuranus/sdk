//
//  SOSFullScreenADView.h
//  Onstar
//
//  Created by TaoLiang on 2019/12/17.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSFullScreenADView : UIView
@property (strong, nonatomic) NSArray<NNBanner *> *banners;
@property (copy, nonatomic) void(^selectBlock)(NSUInteger index);
@property (copy, nonatomic) void (^dismissed)(void);
- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
