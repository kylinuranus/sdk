//
//  SOSRouteInfoView.h
//  Onstar
//
//  Created by Coir on 2019/4/16.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSRouteTool.h"

NS_ASSUME_NONNULL_BEGIN

@class SOSRouteInfoView;
@protocol SOSRouteInfoViewDelegate <NSObject>
- (void)viewTappedWithView:(SOSRouteInfoView *)view;
@end

@interface SOSRouteInfoView : UIView

@property (nonatomic, assign) BOOL viewHilighted;
@property (nonatomic, strong) SOSRouteInfo *routeInfo;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id <SOSRouteInfoViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
