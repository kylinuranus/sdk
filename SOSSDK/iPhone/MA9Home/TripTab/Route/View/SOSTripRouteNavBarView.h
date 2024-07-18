//
//  SOSTripRouteNavBarView.h
//  Onstar
//
//  Created by Coir on 2019/4/15.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SOSTripRouteNavDelegate <NSObject>
- (void)routePOIChangedWithBeginPOI:(SOSPOI *)beginPOI AndEndPOI:(SOSPOI *)endPOI;
@end

@interface SOSTripRouteNavBarView : UIView

/// 仅用于 导航找车 功能
@property (nonatomic, assign) BOOL isFindCarMode;

@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, strong) SOSPOI *beginPOI;
@property (nonatomic, strong) SOSPOI *endPOI;

@property (nonatomic, weak) id <SOSTripRouteNavDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
