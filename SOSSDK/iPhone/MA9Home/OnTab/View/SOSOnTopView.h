//
//  SOSOnTopView.h
//  Onstar
//
//  Created by onstar on 2019/2/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOnTopView : UIView

@property (nonatomic, copy) void (^changeVehicleBlock)(void);
@property (nonatomic, copy) void (^shareCenterBlock)(void);

@end

NS_ASSUME_NONNULL_END
