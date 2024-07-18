//
//  SOSLBSProtocolView.h
//  Onstar
//
//  Created by Coir on 2018/12/21.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSLBSProtocolView : UIView

- (void)show:(BOOL)show;

- (void)setCompleteHanlder:(void (^ __nullable)(BOOL agreeStatus))completion;

@end

NS_ASSUME_NONNULL_END
