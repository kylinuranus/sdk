//
//  SOSPinPasswordView.h
//  Onstar
//
//  Created by onstar on 2018/12/26.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSPinPasswordView : UIView

@property (nonatomic, copy) void(^didCompleteInputBlock)(NSString *pinCode);

@end

NS_ASSUME_NONNULL_END
