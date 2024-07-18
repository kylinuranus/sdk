//
//  SOSAvatarView.h
//  Onstar
//
//  Created by Onstar on 2018/11/22.
//  Copyright © 2018 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSModuleProtocols.h"

NS_ASSUME_NONNULL_BEGIN

//左上角头像
@interface SOSAvatarView : UIView
@property(nonatomic, weak) id<SOSHomeMeTabProtocol> delegate;
@end

NS_ASSUME_NONNULL_END
