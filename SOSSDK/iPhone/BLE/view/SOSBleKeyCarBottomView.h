//
//  SOSBleKeyCarBottomView.h
//  Onstar
//
//  Created by onstar on 2018/10/18.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSBleKeyCarBottomView : UIView

@property (nonatomic, copy) void (^searchButtonClick)(void);

@property (nonatomic, copy) void (^textButtonClick)(void);
@end

NS_ASSUME_NONNULL_END
