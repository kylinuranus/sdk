//
//  SOSBleOwnerShareCell.h
//  Onstar
//
//  Created by onstar on 2018/7/24.
//  Copyright © 2018年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOSAuthorInfo.h"

@interface SOSBleOwnerShareCell : UITableViewCell

- (void)setAuthorEntity:(SOSAuthorDetail *)authorEntity ownerSharePage:(BOOL)owner;

@property (nonatomic, copy) void (^operationButtonTapBlock)(void);

@end
