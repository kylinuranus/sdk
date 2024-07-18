//
//  SOSOnRemoteCell.h
//  Onstar
//
//  Created by onstar on 2018/12/21.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SOSOnRemoteCell : UITableViewCell

@property (nonatomic, copy) void(^tapHVACABlock)(NSInteger type);
@property (nonatomic, copy) void(^tapRemoteBlock)(NSInteger type);
- (void)reload;

@end

NS_ASSUME_NONNULL_END
