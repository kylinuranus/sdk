//
//  SOSSocialContactShareView.h
//  Onstar
//
//  Created by onstar on 2019/4/19.
//  Copyright © 2019 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSSocialContactShareView : UIView
@property (nonatomic, copy) void(^shareTapBlock)(NSInteger index);
@property (nonatomic, copy) void(^shareTapCallback)(NSArray *clickMenu);
@property (nonatomic, strong) NSArray *shareChannels;

@end

NS_ASSUME_NONNULL_END
