//
//  SOSVehicleTabHeaderView.h
//  Onstar
//
//  Created by Onstar on 2018/12/18.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSModuleProtocols.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SOSVehicleHeaderState) {
    SOSVehicleHeaderStateUnlogin,
    SOSVehicleHeaderStateLogin,
    SOSVehicleHeaderStateLoading
};
@interface SOSVehicleTabHeaderView : UIView
@property(nonatomic, weak) id<SOSHomeMeTabProtocol, SOSHomeVehicleTabProtocol> delegate;
@property(nonatomic,assign)SOSVehicleConditonStatus sta;
-(instancetype)initWithFrame:(CGRect)frame;
-(void)baseViewUnloginState;
-(CGFloat)quickStartHeight;
-(void)baseViewInloginState;
-(void)baseViewLoginState;
@end

NS_ASSUME_NONNULL_END
